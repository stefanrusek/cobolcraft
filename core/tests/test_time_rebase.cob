*> Implementation test of the time re-base (T0340; specs/002-client-polish/data-model.md section 6,
*> docs/protocol/07 section 9.2 "Time and clocks", docs/design/cobolcraft-standard-core.md CORE-5): the day is
*> 24,000 ticks and one clock `minecraft:overworld`. A level.dat of feature 001 has no `Clocks` compound and
*> its `Time` is a time of day of a 30,000-tick day: when it opens, the time of day keeps its phase on the
*> standard timeline (old * 24000 / 30000, truncated) and the next save writes `Clocks`, so a second open
*> does not re-base again. A level.dat with `Clocks` reads its `total_ticks` modulo the day.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TIME-REBASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 COPY RULES.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FILE                PIC X(256) VALUE "build/core-test-world/level.dat".
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-OLD                 BINARY-DOUBLE.
 01 WS-NEW                 BINARY-DOUBLE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-INT                 BINARY-LONG.
 01 WS-FILE-PATH           PIC X(1100).
 01 WS-FILE-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "N" TO TL-MODE

     MOVE "test time rebase the day is 24000 ticks" TO TL-CASE
     MOVE 24000 TO TL-EXPECTED-N
     MOVE RULE-DAY-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-OLD
     MOVE "test time rebase 0 stays 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM REBASE-CASE
     MOVE 15000 TO WS-OLD
     MOVE "test time rebase 15000 of 30000 is 12000 of 24000" TO TL-CASE
     MOVE 12000 TO TL-EXPECTED-N
     PERFORM REBASE-CASE
     MOVE 7500 TO WS-OLD
     MOVE "test time rebase 7500 is 6000" TO TL-CASE
     MOVE 6000 TO TL-EXPECTED-N
     PERFORM REBASE-CASE
     MOVE 29999 TO WS-OLD
     MOVE "test time rebase 29999 is 23999 (truncated)" TO TL-CASE
     MOVE 23999 TO TL-EXPECTED-N
     PERFORM REBASE-CASE

*>   A level.dat of feature 001: DataVersion, LevelName, GameMode, Time 15000, no Clocks.
     PERFORM ROOT-BEGIN
     MOVE "Time" TO WN MOVE 4 TO WL
     MOVE 15000 TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM STORE-FILE
     MOVE 0 TO CW-TIME
     CALL "LEVEL-DAT-READ"
     MOVE "test time rebase an old level.dat (Time 15000, no Clocks) opens at 12000" TO TL-CASE
     MOVE 12000 TO TL-EXPECTED-N
     MOVE CW-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "LEVEL-DAT-WRITE"
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "Clocks" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "test time rebase the next save writes Clocks minecraft:overworld total_ticks 12000" TO TL-CASE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "{minecraft:overworld:{total_ticks:12000,partial_tick:0.000,rate:1.000,paused:0}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO CW-TIME
     CALL "LEVEL-DAT-READ"
     MOVE "N" TO TL-MODE
     MOVE "test time rebase a second open reads Clocks and does not re-base again" TO TL-CASE
     MOVE 12000 TO TL-EXPECTED-N
     MOVE CW-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clocks present: its total_ticks wins over Time and is taken modulo the day.
     PERFORM ROOT-BEGIN
     MOVE "Time" TO WN MOVE 4 TO WL
     MOVE 99 TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     MOVE "Clocks" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:overworld" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "total_ticks" TO WN MOVE 11 TO WL
     MOVE 50400 TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM STORE-FILE
     MOVE 0 TO CW-TIME
     CALL "LEVEL-DAT-READ"
     MOVE "test time rebase Clocks total_ticks 50400 opens at 2400 whatever Time says" TO TL-CASE
     MOVE 2400 TO TL-EXPECTED-N
     MOVE CW-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 REBASE-CASE.
     MOVE WS-OLD TO WS-NEW
     CALL "LEVEL-TIME-REBASE" USING WS-NEW
     MOVE WS-NEW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ROOT-BEGIN.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL.

 STORE-FILE.
     MOVE SPACES TO WS-FILE-PATH
     MOVE "build/core-test-world/level.dat" TO WS-FILE-PATH
     MOVE 31 TO WS-FILE-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-FILE-PATH WS-FILE-LENGTH PB-BUFFER.
 END PROGRAM TEST-TIME-REBASE.

 COPY CORETEST.
