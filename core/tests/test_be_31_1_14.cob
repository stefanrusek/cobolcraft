*> Coverage-only additions for core/src/be-31-1.cob (T0841-T0866): the lock and CustomName read of BE-LOAD with an unknown key inside lock,
*> a refused creation on load (result 3), out-of-range registry rows, default name of a type without one, negative open counts and guards.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY BEFX.
 COPY PROTO.
 01 WS-TEXT                PIC X(256).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-CAP                 BINARY-LONG VALUE 1024.
 01 WS-KEY                 PIC X(48).
 01 WS-K24                 PIC X(24).
 01 WS-K32                 PIC X(32).
 01 WS-LEN                 BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-T                   BINARY-LONG.
 01 WS-BOX                 BINARY-LONG.
 01 WS-CH                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-SPEC                BINARY-LONG VALUE 1.
 01 WS-DIR                 BINARY-LONG VALUE 1.
 01 WS-POWER               BINARY-LONG.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-TXT                 PIC X(48).
 01 WS-TL                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "minecraft:chest" TO WS-KEY
     MOVE 15 TO WS-LEN
     MOVE 1 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-CH
     MOVE "coverage US12 31-1: lock with an unknown inner key and a CustomName are read; out-of-range type row is empty" TO TL-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE "lock" TO WN
     MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "junk" TO WN
     MOVE 4 TO WL
     MOVE 7 TO WS-TL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TL
     MOVE "items" TO WN
     MOVE 5 TO WL
     MOVE "minecraft:stick" TO WS-TXT
     MOVE 15 TO WS-TL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TXT WS-TL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "CustomName" TO WN
     MOVE 10 TO WL
     MOVE "Boxy" TO WS-TXT
     MOVE 4 TO WS-TL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TXT WS-TL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-CH PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE 99 TO WS-T
     CALL "BE-TYPE-INFO" USING WS-T WS-K24 WS-LEN WS-OP
     MOVE WS-LEN TO WS-E1
     MOVE BE-LOCK-LENGTH(WS-CH) TO WS-E2
     MOVE 4 TO WS-T
     CALL "BE-DEFAULT-NAME" USING WS-T WS-K32 WS-LEN
     MOVE WS-LEN TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " BE-NAME(WS-CH)(1:4) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "0 15 Boxy 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "coverage US12 31-1: a chunk entry whose block does not fit its type is refused (result 3)" TO TL-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE "id" TO WN
     MOVE 2 TO WL
     MOVE "minecraft:barrel" TO WS-TXT
     MOVE 16 TO WS-TL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TXT WS-TL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-D WS-CX WS-CZ WS-KEY WS-LEN WS-RES WS-NEW
     CALL "PB-FREE" USING PB-BUFFER
     MOVE WS-RES TO WS-E1
     MOVE SPACES TO WS-TEXT
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "coverage US12 31-1: negative trapped chest count gives no power; shulker box negative count resets, removed or spectator ignored" TO TL-CASE
     MOVE "minecraft:shulker_box" TO WS-KEY
     MOVE 21 TO WS-LEN
     MOVE 24 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-BOX
     MOVE -3 TO BE-OPEN-COUNT(WS-CH)
     CALL "BE-TRAPPED-POWER" USING WS-CH WS-DIR WS-POWER
     MOVE WS-POWER TO WS-E1
     MOVE -2 TO BE-OPEN-COUNT(WS-BOX)
     MOVE 0 TO WS-SPEC
     CALL "BE-SHULKER-START" USING WS-BOX WS-SPEC BE-FX
     MOVE BE-OPEN-COUNT(WS-BOX) TO WS-E2
     MOVE 1 TO WS-SPEC
     CALL "BE-SHULKER-STOP" USING WS-BOX WS-SPEC BE-FX
     MOVE BE-OPEN-COUNT(WS-BOX) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-BE-31-1-14.

 COPY CORETEST.
