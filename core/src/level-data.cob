*> level.dat handling (data-model section 6; docs/protocol/07 section 9.2; world-types section 2.1): the time re-base and the
*> level.dat reader and writer (LEVEL-DAT-WRITE, LEVEL-DAT-READ), split from persistence.cob (T0331).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-TIME-REBASE.
*> USING time (BINARY-DOUBLE, in and out): a time of day of the 30,000-tick day of a level.dat of feature 001
*> becomes the same phase of the standard 24,000-tick day: time * 24000 / 30000, truncated. (The phase rule
*> is an assumption: the documents say "re-based by the standard timeline" without a formula.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RULES.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TIME.
     COMPUTE L-TIME = L-TIME * RULE-DAY-LENGTH / RULE-OLD-DAY-LENGTH
     GOBACK.
 END PROGRAM LEVEL-TIME-REBASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-DAT-WRITE.
*> No parameters: writes <world>/level.dat (07 §9.2): DataVersion, LevelName, GameMode, Time,
*> Spawn {Dimension (always cobolcraft:main, standin §5.2), X, Y, Z, Yaw} and Weather (the five fields of
*> the shared state of 33 section 10 and an entry named by the dimension key, {Kind, Remaining}, for every enabled dimension
*> that has weather; the kind is the skin of the flags).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-INT                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/level.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "LevelName" TO WN MOVE 9 TO WL
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CW-NAME TRAILING)) TO WS-INT
     IF CW-NAME = SPACES
         MOVE 0 TO WS-INT
     END-IF
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL CW-NAME WS-INT
     MOVE "WorldType" TO WN MOVE 9 TO WL
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CW-WORLD-TYPE TRAILING)) TO WS-INT
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL CW-WORLD-TYPE WS-INT
     MOVE "Seed" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL CW-SEED
     IF CW-CONTENT-JAR NOT = SPACES
         MOVE "ContentJar" TO WN MOVE 10 TO WL
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CW-CONTENT-JAR TRAILING)) TO WS-INT
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL CW-CONTENT-JAR WS-INT
     END-IF
     MOVE "GameMode" TO WN MOVE 8 TO WL
     MOVE CW-GAME-MODE TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "Time" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL CW-TIME
*>   Clocks (07 §9.2): the one clock minecraft:overworld (CORE-5); its total_ticks is the time of day.
     MOVE "Clocks" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:overworld" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "total_ticks" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL CW-TIME
     MOVE "partial_tick" TO WN MOVE 12 TO WL
     MOVE 0 TO WS-FLOAT
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
     MOVE "rate" TO WN MOVE 4 TO WL
     MOVE 1 TO WS-FLOAT
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
     MOVE "paused" TO WN MOVE 6 TO WL
     MOVE 0 TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "Spawn" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Dimension" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL DM-KEY(DIM-MAIN) DM-KEY-LENGTH(DIM-MAIN)
     MOVE "X" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL CW-SPAWN-X
     MOVE "Y" TO WN
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL CW-SPAWN-Y
     MOVE "Z" TO WN
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL CW-SPAWN-Z
     MOVE "Yaw" TO WN MOVE 3 TO WL
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL CW-SPAWN-YAW
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "Weather" TO WN MOVE 7 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
*>   The shared state of 33 section 10 (07 section 9.2 "Standard world"), then the cobolcraft entry of each dimension
*>   with weather, its kind being the skin of the flags (07 section 9.2 "Cobolcraft world").
     MOVE "clear_weather_time" TO WN MOVE 18 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL CW-CLEAR-TIME
     MOVE "rain_time" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL CW-RAIN-TIME
     MOVE "thunder_time" TO WN MOVE 12 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL CW-THUNDER-TIME
     MOVE "raining" TO WN MOVE 7 TO WL
     MOVE CW-RAINING TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     MOVE "thundering" TO WN MOVE 10 TO WL
     MOVE CW-THUNDERING TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     MOVE WK-CLEAR TO WS-KIND
     MOVE CW-CLEAR-TIME TO WS-LEFT
     IF CW-RAINING = 1
         MOVE WK-DRIZZLE TO WS-KIND
         MOVE CW-RAIN-TIME TO WS-LEFT
         IF CW-THUNDERING = 1
             MOVE WK-HAILSTORM TO WS-KIND
         END-IF
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         IF DM-WEATHER(WS-DIM) = 1
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER DM-KEY(WS-DIM)
                 DM-KEY-LENGTH(WS-DIM)
             MOVE "Kind" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WK-KEY(WS-KIND)
                 WK-KEY-LENGTH(WS-KIND)
             MOVE "Remaining" TO WN MOVE 9 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-LEFT
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     GOBACK.
 END PROGRAM LEVEL-DAT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-DAT-READ.
*> No parameters: reads <world>/level.dat into the world (07 §9.2): LevelName, GameMode, Time, the
*> spawn point and the weather of every dimension it names that the game knows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 COPY RULES.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-TYPE-CAPACITY       BINARY-LONG VALUE 10.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OLD-TIME            BINARY-DOUBLE.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-HAS-TIME            PIC 9 VALUE 0.
 01 WS-HAS-CLOCK           PIC 9 VALUE 0.
 01 WS-HAS-WEATHER         PIC 9 VALUE 0.
 01 WS-LEGACY-KIND         BINARY-LONG.
 01 WS-LEGACY-LEFT         BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/level.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     MOVE 0 TO WS-HAS-TIME WS-HAS-CLOCK WS-HAS-WEATHER WS-LEGACY-KIND
     CALL "PERSIST-READ-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "LevelName" AND WS-TYPE = 8
                 MOVE SPACES TO CW-NAME
                 CALL "NBT-READ-STRING" USING PB-BUFFER CW-NAME WS-TEXT-CAPACITY WS-INT
             WHEN WN = "GameMode" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                 MOVE WS-INT TO CW-GAME-MODE
             WHEN WN = "WorldType" AND WS-TYPE = 8
                 MOVE SPACES TO CW-WORLD-TYPE
                 CALL "NBT-READ-STRING" USING PB-BUFFER CW-WORLD-TYPE WS-TYPE-CAPACITY WS-INT
             WHEN WN = "Seed" AND WS-TYPE = 4
                 CALL "PB-GET-LONG" USING PB-BUFFER CW-SEED
             WHEN WN = "ContentJar" AND WS-TYPE = 8
                 MOVE SPACES TO CW-CONTENT-JAR
                 CALL "NBT-READ-STRING" USING PB-BUFFER CW-CONTENT-JAR WS-TEXT-CAPACITY WS-INT
             WHEN WN = "Time" AND WS-TYPE = 4
                 CALL "PB-GET-LONG" USING PB-BUFFER WS-OLD-TIME
                 MOVE 1 TO WS-HAS-TIME
             WHEN WN = "Clocks" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                         WS-NAME-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     IF WN = "minecraft:overworld" AND WS-INNER-TYPE = 10
                         PERFORM UNTIL PB-ERROR = 1
                             MOVE SPACES TO WN
                             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                                 WS-NAME-CAPACITY WL
                             IF WS-INNER-TYPE = 0
                                 EXIT PERFORM
                             END-IF
                             IF WN = "total_ticks" AND WS-INNER-TYPE = 4
                                 CALL "PB-GET-LONG" USING PB-BUFFER WS-TICKS
                                 MOVE 1 TO WS-HAS-CLOCK
                             ELSE
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                             END-IF
                         END-PERFORM
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-IF
                 END-PERFORM
             WHEN WN = "Spawn" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                         WS-NAME-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "X" AND WS-INNER-TYPE = 6
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER CW-SPAWN-X
                         WHEN WN = "Y" AND WS-INNER-TYPE = 6
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER CW-SPAWN-Y
                         WHEN WN = "Z" AND WS-INNER-TYPE = 6
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER CW-SPAWN-Z
                         WHEN WN = "Yaw" AND WS-INNER-TYPE = 5
                             CALL "PB-GET-FLOAT" USING PB-BUFFER CW-SPAWN-YAW
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-EVALUATE
                 END-PERFORM
             WHEN WN = "Weather" AND WS-TYPE = 10
*>               The five fields of the shared state, else one compound per dimension key: {Kind, Remaining}
*>               (a world of the cobolcraft form before the shared state: the kind is read as the flags).
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                         WS-NAME-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "clear_weather_time" AND WS-INNER-TYPE = 3
                             CALL "PB-GET-INT" USING PB-BUFFER CW-CLEAR-TIME
                             MOVE 1 TO WS-HAS-WEATHER
                         WHEN WN = "rain_time" AND WS-INNER-TYPE = 3
                             CALL "PB-GET-INT" USING PB-BUFFER CW-RAIN-TIME
                         WHEN WN = "thunder_time" AND WS-INNER-TYPE = 3
                             CALL "PB-GET-INT" USING PB-BUFFER CW-THUNDER-TIME
                         WHEN WN = "raining" AND WS-INNER-TYPE = 1
                             CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                             MOVE 0 TO CW-RAINING
                             IF WS-INT NOT = 0
                                 MOVE 1 TO CW-RAINING
                             END-IF
                         WHEN WN = "thundering" AND WS-INNER-TYPE = 1
                             CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                             MOVE 0 TO CW-THUNDERING
                             IF WS-INT NOT = 0
                                 MOVE 1 TO CW-THUNDERING
                             END-IF
                         WHEN WS-INNER-TYPE = 10
                             MOVE 0 TO WS-DIM WS-KIND
                             MOVE WEATHER-UNTIL-CHANGED TO WS-LEFT
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
                                 IF DM-KEY(WS-I) = WN
                                     MOVE WS-I TO WS-DIM
                                 END-IF
                             END-PERFORM
                             PERFORM UNTIL PB-ERROR = 1
                                 MOVE SPACES TO WN
                                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                                     WS-NAME-CAPACITY WL
                                 IF WS-INNER-TYPE = 0
                                     EXIT PERFORM
                                 END-IF
                                 EVALUATE TRUE
                                     WHEN WN = "Kind" AND WS-INNER-TYPE = 8
                                         MOVE SPACES TO WS-KEY
                                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-NAME-CAPACITY
                                             WS-KEY-LENGTH
                                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WEATHER-KIND-COUNT
                                             IF WK-KEY(WS-I) = WS-KEY
                                                 MOVE WS-I TO WS-KIND
                                             END-IF
                                         END-PERFORM
                                     WHEN WN = "Remaining" AND WS-INNER-TYPE = 3
                                         CALL "PB-GET-INT" USING PB-BUFFER WS-LEFT
                                     WHEN OTHER
                                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                                 END-EVALUATE
                             END-PERFORM
                             IF WS-DIM > 0 AND WS-KIND > 0
                                 MOVE WS-KIND TO WS-LEGACY-KIND
                                 MOVE WS-LEFT TO WS-LEGACY-LEFT
                             END-IF
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-EVALUATE
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
*>   A weather of the cobolcraft form of before the shared state: the kind is the flags, the remaining time the clear time or
*>   the rain and thunder time (until changed: the longest time).
     IF WS-HAS-WEATHER = 0 AND WS-LEGACY-KIND > 0
         IF WS-LEGACY-LEFT < 0
             MOVE 2147483647 TO WS-LEGACY-LEFT
         END-IF
         CALL "WEATHER-SET-KIND" USING WS-LEGACY-KIND WS-LEGACY-LEFT
     END-IF
     CALL "WEATHER-LEVELS-LOAD"
*>   The time of day: the clock's total_ticks modulo the day, else the Time of a world of feature 001,
*>   re-based onto the standard day.
     EVALUATE TRUE
         WHEN WS-HAS-CLOCK = 1
             COMPUTE CW-TIME = FUNCTION MOD(WS-TICKS, RULE-DAY-LENGTH)
         WHEN WS-HAS-TIME = 1
             MOVE WS-OLD-TIME TO CW-TIME
             CALL "LEVEL-TIME-REBASE" USING CW-TIME
     END-EVALUATE
     GOBACK.
 END PROGRAM LEVEL-DAT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-PEEK-TYPE.
*> USING found out (BINARY-LONG: 0 no level.dat or no WorldType key, 1 a String, 2 a tag
*> of another type), text out (PIC X(32), the String; spaces otherwise): reads only the WorldType key of the folder's
*> level.dat, so the content type can be chosen before the world is loaded (world-types section 2.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/level.dat".
 LINKAGE SECTION.
 01 L-FOUND                BINARY-LONG.
 01 L-TEXT                 PIC X(32).
 PROCEDURE DIVISION USING L-FOUND L-TEXT.
     MOVE 0 TO L-FOUND
     MOVE SPACES TO L-TEXT
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-READ-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "WorldType"
             IF WS-TYPE = 8
                 MOVE 1 TO L-FOUND
                 CALL "NBT-READ-STRING" USING PB-BUFFER L-TEXT WS-TEXT-CAPACITY WS-LENGTH
             ELSE
                 MOVE 2 TO L-FOUND
             END-IF
             EXIT PERFORM
         END-IF
         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
     END-PERFORM
     GOBACK.
 END PROGRAM LEVEL-PEEK-TYPE.
