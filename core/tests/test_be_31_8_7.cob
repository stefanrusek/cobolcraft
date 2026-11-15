*> Test of 31-8 section 7, Sculk catalyst (core/src/be-31-8.cob; T0979): the cursor list persistence, addCursors, the event handler, the merge pass, the bloom constants.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-8-7.
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
     MOVE "acceptance US12 31-8§7 Sculk catalyst: fresh catalyst (7.1): the cursors list is always written, an empty list when there are none" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{cursors:[]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§7 Sculk catalyst: addCursors (7.3, validation 10): a reward of 5 makes one cursor of charge 5 (decay_delay 1, update_delay 0, no facings), 1500 makes cursors of 1000 and 500, nothing for 0, and at most 32" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 5 TO WS-A
     CALL "BE8-ADD-CURSORS" USING WS-IDX WS-X WS-Y WS-Z WS-A
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE 1500 TO WS-A
     CALL "BE8-ADD-CURSORS" USING WS-IDX WS-X WS-Y WS-Z WS-A
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 11) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 18) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 12) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 13) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     CALL "BE8-ADD-CURSORS" USING WS-IDX WS-X WS-Y WS-Z WS-A
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE 40000 TO WS-A
     CALL "BE8-ADD-CURSORS" USING WS-IDX WS-X WS-Y WS-Z WS-A
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 5 3 1000 500 1 0 3 32" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§7 Sculk catalyst: persistence (7.1): the cursors list holds {pos, charge, decay_delay, update_delay, facings}; facings is a list of direction names, written only when present" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-UUID(WS-IDX, 1)
     MOVE 2 TO BE-UUID(WS-IDX, 2)
     MOVE 3 TO BE-UUID(WS-IDX, 3)
     MOVE 7 TO BE-UUID(WS-IDX, 4)
     MOVE 1 TO BE-UUID(WS-IDX, 5)
     MOVE 0 TO BE-UUID(WS-IDX, 6)
     MOVE -1 TO BE-UUID(WS-IDX, 7)
     MOVE 4 TO BE-UUID(WS-IDX, 8)
     MOVE 5 TO BE-UUID(WS-IDX, 9)
     MOVE 6 TO BE-UUID(WS-IDX, 10)
     MOVE 1000 TO BE-UUID(WS-IDX, 11)
     MOVE 0 TO BE-UUID(WS-IDX, 12)
     MOVE 9 TO BE-UUID(WS-IDX, 13)
     MOVE 5 TO BE-UUID(WS-IDX, 14)
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE WS-IDX TO WS-U
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
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
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{cursors:[{pos:I[1,2,3],charge:7,decay_delay:1,update_delay:0},{pos:I[4,5,6],charge:1000,decay_delay" &
         ":0,update_delay:9,facings:[down,north]}]} {cursors:[{pos:I[1,2,3],charge:7,decay_delay:1,update_dela" &
         "y:0},{pos:I[4,5,6],charge:1000,decay_delay:0,update_delay:9,facings:[down,north]}]} 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§7 Sculk catalyst: lenient cursor load (7.1): decay_delay defaults to 1, update_delay to 0, charge to 0, a facings list of names becomes the set; an entry with a charge outside 0 to 1000, a decay_delay above" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "facings" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "east" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "down" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 2000 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     MOVE "decay_delay" TO WS-NM
     MOVE 11 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     MOVE "update_delay" TO WS-NM
     MOVE 12 TO WS-NML
     MOVE -1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 33 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 0 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 2 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 3 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 4 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 5 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 6 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 7 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 8 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 9 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 10 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 11 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 12 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 13 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 14 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 15 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 16 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 17 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 18 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 19 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 20 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 21 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 22 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 23 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 24 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 25 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 26 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 27 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 28 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 29 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 30 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 31 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 32 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 32 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 0 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 2 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 3 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 4 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 5 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 6 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 7 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 8 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 9 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 10 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 11 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 12 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 13 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 14 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 15 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 16 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 17 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 18 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 19 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 20 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 21 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 22 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 23 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 24 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 25 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 26 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 27 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 28 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 29 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 30 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 31 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{cursors:[{pos:I[1,2,3],charge:0,decay_delay:1,update_delay:0,facings:[down,east]}]} {cursors:[]} {c" &
         "ursors:[]} {cursors:[]} {cursors:[]} {cursors:[]} 32" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§7 Sculk catalyst: facings (7.1): the names of all six directions are read into a set (a duplicate or an unknown name changes nothing), an element of the wrong type is skipped, an unknown key of an entry is" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 1 TO WS-IAV(2)
     MOVE 1 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     MOVE "facings" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 8 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "down" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "up" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "north" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "south" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "west" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "east" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "down" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "zzz" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cursors" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 2 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 2 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "charge" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     MOVE "facings" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 3 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{cursors:[{pos:I[1,1,1],charge:5,decay_delay:1,update_delay:0,facings:[down,up,north,south,west,east" &
         "]}]} {cursors:[{pos:I[2,2,2],charge:5,decay_delay:1,update_delay:0,facings:[]}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§7 Sculk catalyst: handleGameEvent (7.2, validation 10): only entity_die of a living entity; an entity whose experience was consumed skips to the end; otherwise cursors for a positive reward of an entity that" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     MOVE 5 TO WS-F
     CALL "BE8-CAT-HANDLE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q WS-R
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-R TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     CALL "BE8-CAT-HANDLE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q WS-R
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-R TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 5 TO WS-F
     CALL "BE8-CAT-HANDLE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q WS-R
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-R TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 5 TO WS-F
     CALL "BE8-CAT-HANDLE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q WS-R
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-R TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     MOVE 5 TO WS-F
     CALL "BE8-CAT-HANDLE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q WS-R
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-R TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     MOVE 5 TO WS-F
     CALL "BE8-CAT-HANDLE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P WS-Q WS-R
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-Q TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-R TO WS-SHOW
     PERFORM ADD-N
     MOVE "5 1 1 1 1 0 1 1 0 1 0 1 1 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§7 Sculk catalyst: position merge (7.3): cursors farther than 1024 (Chebyshev) are dropped, a cursor with charge 0 sends level event 3006 with data 0 and is dropped, two cursors on one position merge when the" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:sculk_catalyst" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 36 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 7 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-UUID(WS-IDX, 1)
     MOVE 2 TO BE-UUID(WS-IDX, 2)
     MOVE 3 TO BE-UUID(WS-IDX, 3)
     MOVE 100 TO BE-UUID(WS-IDX, 4)
     MOVE 1 TO BE-UUID(WS-IDX, 5)
     MOVE 5 TO BE-UUID(WS-IDX, 6)
     MOVE -1 TO BE-UUID(WS-IDX, 7)
     MOVE 1 TO BE-UUID(WS-IDX, 8)
     MOVE 2 TO BE-UUID(WS-IDX, 9)
     MOVE 3 TO BE-UUID(WS-IDX, 10)
     MOVE 200 TO BE-UUID(WS-IDX, 11)
     MOVE 1 TO BE-UUID(WS-IDX, 12)
     MOVE 2 TO BE-UUID(WS-IDX, 13)
     MOVE -1 TO BE-UUID(WS-IDX, 14)
     MOVE 9 TO BE-UUID(WS-IDX, 15)
     MOVE 9 TO BE-UUID(WS-IDX, 16)
     MOVE 9 TO BE-UUID(WS-IDX, 17)
     MOVE 0 TO BE-UUID(WS-IDX, 18)
     MOVE 1 TO BE-UUID(WS-IDX, 19)
     MOVE 0 TO BE-UUID(WS-IDX, 20)
     MOVE -1 TO BE-UUID(WS-IDX, 21)
     MOVE 5000 TO BE-UUID(WS-IDX, 22)
     MOVE 0 TO BE-UUID(WS-IDX, 23)
     MOVE 0 TO BE-UUID(WS-IDX, 24)
     MOVE 50 TO BE-UUID(WS-IDX, 25)
     MOVE 1 TO BE-UUID(WS-IDX, 26)
     MOVE 0 TO BE-UUID(WS-IDX, 27)
     MOVE -1 TO BE-UUID(WS-IDX, 28)
     MOVE 7 TO BE-UUID(WS-IDX, 29)
     MOVE 7 TO BE-UUID(WS-IDX, 30)
     MOVE 7 TO BE-UUID(WS-IDX, 31)
     MOVE 700 TO BE-UUID(WS-IDX, 32)
     MOVE 1 TO BE-UUID(WS-IDX, 33)
     MOVE 3 TO BE-UUID(WS-IDX, 34)
     MOVE 5 TO BE-UUID(WS-IDX, 35)
     MOVE 7 TO BE-UUID(WS-IDX, 36)
     MOVE 7 TO BE-UUID(WS-IDX, 37)
     MOVE 7 TO BE-UUID(WS-IDX, 38)
     MOVE 600 TO BE-UUID(WS-IDX, 39)
     MOVE 1 TO BE-UUID(WS-IDX, 40)
     MOVE 1 TO BE-UUID(WS-IDX, 41)
     MOVE 5 TO BE-UUID(WS-IDX, 42)
     MOVE 7 TO BE-UUID(WS-IDX, 43)
     MOVE 7 TO BE-UUID(WS-IDX, 44)
     MOVE 7 TO BE-UUID(WS-IDX, 45)
     MOVE 50 TO BE-UUID(WS-IDX, 46)
     MOVE 1 TO BE-UUID(WS-IDX, 47)
     MOVE 9 TO BE-UUID(WS-IDX, 48)
     MOVE 5 TO BE-UUID(WS-IDX, 49)
     MOVE 0 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "BE8-MERGE" USING WS-IDX WS-X WS-Y WS-Z WS-TAB3 WS-A
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 11) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 13) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 15) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 18) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-UUID(WS-IDX, 20) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(5) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(6) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(7) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV3(8) TO WS-SHOW
     PERFORM ADD-N
     MOVE "3 2 1 300 2 7 700 3 7 650 1 9 9 9 0 7 7 7 261" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§7 Sculk catalyst: bloom (7.4): a tick after 8 ticks, two sculk_soul particles, the sound at volume 2.0 and pitch 0.6 + nextFloat * 0.4 (draw in; pitch, delay, particles, volume out)" TO TL-CASE
     PERFORM BEGIN-CASE
     COMPUTE WS-FS1 = 0.0
     CALL "BE8-BLOOM" USING WS-FS1 WS-FS2 WS-A WS-B WS-C
     COMPUTE WS-SHOW ROUNDED = (WS-FS2) * 10000
     PERFORM ADD-N
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 0.5
     CALL "BE8-BLOOM" USING WS-FS1 WS-FS2 WS-A WS-B WS-C
     COMPUTE WS-SHOW ROUNDED = (WS-FS2) * 10000
     PERFORM ADD-N
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 0.75
     CALL "BE8-BLOOM" USING WS-FS1 WS-FS2 WS-A WS-B WS-C
     COMPUTE WS-SHOW ROUNDED = (WS-FS2) * 10000
     PERFORM ADD-N
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "6000 8 2 2 8000 8 2 2 9000 8 2 2" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-8-7.

 COPY CORETEST.
