*> Test of 31-4 section 2, Jukebox (core/src/be-31-4.cob; T0907): the song length rules, the song player events and tick, setTheItem, the container rules, the signal, persistence with the resume of a loaded tick count.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-4-2.
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
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-FD                FLOAT-LONG.
 01 WS-FE                FLOAT-LONG.
 01 WS-FF                FLOAT-LONG.
 01 WS-FG                FLOAT-LONG.
 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-TX                 PIC X(64).
 01 WS-DROPS.
    05 WS-DROP            OCCURS 4 TIMES.
       10 WS-DROP-ITEM    BINARY-LONG.
       10 WS-DROP-COUNT   BINARY-LONG.
       10 WS-DROP-VAR     BINARY-LONG.
 01 WS-KINDS.
    05 WS-KIND            BINARY-LONG OCCURS 6 TIMES.
 01 WS-DRAWS.
    05 WS-DRAW            BINARY-LONG OCCURS 16 TIMES.
 COPY CTRECIPE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-4§2 Jukebox: song length (2.1): lengthInTicks = ceil(length_in_seconds * 20) in float arithmetic (178 s is 3560); hasFinished(t) is t >= lengthInTicks + 20" TO TL-CASE
     PERFORM BEGIN-CASE
     COMPUTE WS-FA = 178.0
     MOVE WS-FA TO BE-XF(1, 1)
     CALL "BE4-SONG-TICKS" USING BE-XF(1, 1) WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FA = 59.1
     MOVE WS-FA TO BE-XF(1, 1)
     CALL "BE4-SONG-TICKS" USING BE-XF(1, 1) WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FA = 0.05
     MOVE WS-FA TO BE-XF(1, 1)
     CALL "BE4-SONG-TICKS" USING BE-XF(1, 1) WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FA = 1.0
     MOVE WS-FA TO BE-XF(1, 1)
     CALL "BE4-SONG-TICKS" USING BE-XF(1, 1) WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FA = 2.5
     MOVE WS-FA TO BE-XF(1, 1)
     CALL "BE4-SONG-TICKS" USING BE-XF(1, 1) WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE 3579 TO WS-A
     MOVE 3560 TO WS-B
     CALL "BE4-SONG-FINISHED" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3580 TO WS-A
     MOVE 3560 TO WS-B
     CALL "BE4-SONG-FINISHED" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3581 TO WS-A
     MOVE 3560 TO WS-B
     CALL "BE4-SONG-FINISHED" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE4-SONG-FINISHED" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 20 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE4-SONG-FINISHED" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 19 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE4-SONG-FINISHED" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "3560 1182 1 20 50 0 1 1 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: song player (2.4, worked example): play sets the song and ticks 0 with level event 1010 and the song id; ticks 0, 20, ... 3560 emit jukebox_play (179 times); the tick that sees 3580 stops it" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 13 TO WS-A
     MOVE 3560 TO WS-B
     CALL "BE4-JUKEBOX-PLAY" USING WS-IDX WS-A WS-B WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3600
     CALL "BE4-JUKEBOX-TICK" USING WS-IDX WS-A WS-C
     ADD WS-A TO WS-G
     IF WS-C = 1
     MOVE WS-J TO WS-H
     END-IF
     END-PERFORM
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1010 13 1 0 179 3581 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: stop (2.4): nothing happens without a song; with one the song is cleared, ticks reset and level event 1011 is raised" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "BE4-JUKEBOX-STOP" USING WS-IDX WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 7 TO WS-A
     MOVE 100 TO WS-B
     CALL "BE4-JUKEBOX-PLAY" USING WS-IDX WS-A WS-B WS-E WS-F
     CALL "BE4-JUKEBOX-STOP" USING WS-IDX WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 1 1011 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: setTheItem (2.3): a disc with a song is stored, has_record is set, the song starts (event 1010) and the comparator output is the song's; an empty slot clears has_record, stops the song (1011) and" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 5 TO WS-E
     MOVE 3560 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE4-JUKEBOX-SET-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-EV
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-EV TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-B
     MOVE -1 TO WS-E
     CALL "BE4-JUKEBOX-SET-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-EV
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-EV TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     CALL "BE4-JUKEBOX-SET-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-EV
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-EV TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1010 1 5 1 1 0 1011 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: container rules (2.3): canPlaceItem needs a jukebox_playable stack and an empty slot; canTakeItem needs the destination to have an empty slot" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE4-JUKEBOX-RULES" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE4-JUKEBOX-RULES" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE4-JUKEBOX-RULES" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE4-JUKEBOX-RULES" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE4-JUKEBOX-RULES" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: signal (2.5): ownSignal is 15 while the song player plays, else 0; the comparator output is that of the stored disc" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "BE4-JUKEBOX-SIGNAL" USING WS-IDX WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 100 TO WS-B
     CALL "BE4-JUKEBOX-PLAY" USING WS-IDX WS-A WS-B WS-E WS-F
     CALL "BE4-JUKEBOX-SIGNAL" USING WS-IDX WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 15 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: save (2.2): RecordItem when the stored item is not empty and ticks_since_song_started (a Long) while a song plays; an idle jukebox with an item saves only RecordItem" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 2 TO WS-FORM
     MOVE 1 TO WS-A
     MOVE 100 TO WS-B
     CALL "BE4-JUKEBOX-PLAY" USING WS-IDX WS-A WS-B WS-E WS-F
     MOVE 40 TO BE-XI(WS-IDX, 1)
     PERFORM SAVE-RENDER
     MOVE 0 TO BE-XI(WS-IDX, 2)
     PERFORM SAVE-RENDER
     MOVE "{RecordItem:{id:cobolcraft:greystone,count:1},ticks_since_song_started:40} {RecordItem:{id:cobolcraf" &
         "t:greystone,count:1}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: load (2.2, V2): the record loads; a stored tick count of 4000 for the 3560-tick song is finished, so the resume is ignored and saving writes RecordItem only; 500 resumes the song at tick 500" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "RecordItem" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE 2 TO WS-ITEM
     MOVE 1 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     MOVE "ticks_since_song_started" TO WS-NM
     MOVE 24 TO WS-NML
     MOVE 4000 TO WS-LV
     PERFORM NB-LONG
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 3560 TO WS-B
     CALL "BE4-JUKEBOX-RESUME" USING WS-IDX WS-A WS-B WS-E
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "RecordItem" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE 2 TO WS-ITEM
     MOVE 1 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     MOVE "ticks_since_song_started" TO WS-NM
     MOVE 24 TO WS-NML
     MOVE 500 TO WS-LV
     PERFORM NB-LONG
     PERFORM LOAD-BUFFER
     CALL "BE4-JUKEBOX-RESUME" USING WS-IDX WS-A WS-B WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "BE4-JUKEBOX-RESUME" USING WS-IDX WS-A WS-B WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 {RecordItem:{id:cobolcraft:greystone,count:1}} 1 1 500 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-4§2 Jukebox: load of another record (2.2 step 2, V3): while a song plays a RecordItem of another disc stops the player before the new item is stored" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:jukebox" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 4 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "RecordItem" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE 2 TO WS-ITEM
     MOVE 1 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     MOVE "ticks_since_song_started" TO WS-NM
     MOVE 24 TO WS-NML
     MOVE 500 TO WS-LV
     PERFORM NB-LONG
     PERFORM LOAD-BUFFER
     CALL "BE4-JUKEBOX-RESUME" USING WS-IDX WS-A WS-B WS-E
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "RecordItem" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE 3 TO WS-ITEM
     MOVE 1 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-ITEM(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 3" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-4-2.

 COPY CORETEST.
