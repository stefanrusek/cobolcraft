*> A world folder in the 26.3 layout (docs/protocol/07 section 10): level.dat with the compound `Data`, and the saved-data
*> files data/minecraft/{weather,world_clocks,game_rules}.dat. The core reads them when the level is opened
*> (VANILLA-SAVED-READ) and writes them back on every save (VANILLA-LEVEL-WRITE) without losing what it does not model:
*> every child of `Data` and of a saved-data file that the core does not own is copied from the file as it was (raw bytes,
*> VFMT-COPY-OTHERS), and the old level.dat stays as level.dat_old (10.2). Folders in the CobolCraft layout (07 section 9)
*> never reach this file: LEVEL-DAT-WRITE calls it only when CW-LAYOUT is 1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VFMT-OPEN-OLD.
*> USING suffix (PIC X(128): the path inside the world folder), key (PIC X(16), space filled: the compound to find),
*> old PB-BUFFER (initialised by the caller), found out (BINARY-LONG): 1 when the file exists, reads as gzip NBT and its
*> root holds a compound of that name; the buffer is then positioned at the first child of that compound. 0 otherwise
*> (a missing or unreadable file is not an error here, 07 §10.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-Z-PATH              PIC X(1101).
 01 WS-INFO                PIC X(16).
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SUFFIX               PIC X(128).
 01 L-KEY                  PIC X(16).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-SUFFIX L-KEY PB-BUFFER L-FOUND.
     MOVE 0 TO L-FOUND
     CALL "PERSIST-PATH" USING L-SUFFIX WS-PATH WS-LENGTH
     MOVE SPACES TO WS-Z-PATH
     STRING WS-PATH(1:WS-LENGTH) X"00" DELIMITED BY SIZE INTO WS-Z-PATH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-Z-PATH WS-INFO
     IF RETURN-CODE NOT = 0
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "NBT-FILE-READ" USING WS-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME NOT = 0
         GOBACK
     END-IF
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1 OR L-FOUND = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WS-TYPE = 10 AND WN = L-KEY
             MOVE 1 TO L-FOUND
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VFMT-OPEN-OLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VFMT-COPY-OTHERS.
*> USING old PB-BUFFER (positioned at a compound's first child by VFMT-OPEN-OLD), new PB-BUFFER (inside the compound being
*> written), owned (PIC X(512): the child names the caller writes itself, each between bars as "|name|"), mode
*> (BINARY-LONG: 0 names from the list, 1 game-rule keys: a child is owned when its key, without "minecraft:", names a
*> rule of the core), found (BINARY-LONG, the result of VFMT-OPEN-OLD): every other child is appended to the new
*> buffer exactly as it stands in the old one (header and payload bytes). Nothing is copied when found is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-NEEDLE              PIC X(70).
 01 WS-HITS                BINARY-LONG.
 01 WS-RULE                PIC X(40).
 01 WS-INDEX               BINARY-LONG.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X BASED.
 LINKAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 L-OWNED                PIC X(512).
 01 L-MODE                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER WK-BUFFER L-OWNED L-MODE L-FOUND.
     IF L-FOUND = 0
         GOBACK
     END-IF
     PERFORM UNTIL PB-ERROR = 1
         MOVE PB-POS TO WS-START
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         MOVE PB-POS TO WS-END
         MOVE 0 TO WS-HITS
         IF L-MODE = 0
             MOVE SPACES TO WS-NEEDLE
             STRING "|" WN(1:WL) "|" DELIMITED BY SIZE INTO WS-NEEDLE
             INSPECT L-OWNED TALLYING WS-HITS FOR ALL WS-NEEDLE(1:WL + 2)
         ELSE
             MOVE SPACES TO WS-RULE
             IF WL > 10 AND WL <= 50 AND WN(1:10) = "minecraft:"
                 MOVE WN(11:WL - 10) TO WS-RULE
                 CALL "BR-RULE-FIND" USING WS-RULE WS-INDEX
                 IF WS-INDEX > 0
                     MOVE 1 TO WS-HITS
                 END-IF
             END-IF
         END-IF
         IF WS-HITS = 0 AND PB-ERROR = 0
             COMPUTE WS-SIZE = WS-END - WS-START
             SET WS-POINTER TO PB-ADDR
             SET WS-POINTER UP BY WS-START
             SET ADDRESS OF B-SLICE TO WS-POINTER
             CALL "PB-APPEND-BYTES" USING WK-BUFFER B-SLICE WS-SIZE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VFMT-COPY-OTHERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VFMT-EPOCH-MS.
*> USING ms out (BINARY-DOUBLE): the current time in milliseconds since 1970-01-01 UTC (level.dat LastPlayed, 07 §10.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 PIC X(21).
 01 WS-DAYS                BINARY-LONG.
 01 WS-ZONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MS                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-MS.
     MOVE FUNCTION CURRENT-DATE TO WS-NOW
     COMPUTE WS-DAYS = FUNCTION INTEGER-OF-DATE(FUNCTION NUMVAL(WS-NOW(1:8)))
         - FUNCTION INTEGER-OF-DATE(19700101)
     COMPUTE WS-ZONE = FUNCTION NUMVAL(WS-NOW(18:2)) * 3600 + FUNCTION NUMVAL(WS-NOW(20:2)) * 60
     IF WS-NOW(17:1) = "-"
         COMPUTE WS-ZONE = 0 - WS-ZONE
     END-IF
     COMPUTE L-MS = (WS-DAYS * 86400 + FUNCTION NUMVAL(WS-NOW(9:2)) * 3600
         + FUNCTION NUMVAL(WS-NOW(11:2)) * 60 + FUNCTION NUMVAL(WS-NOW(13:2)) - WS-ZONE) * 1000
     GOBACK.
 END PROGRAM VFMT-EPOCH-MS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VFMT-SAVED-END.
*> USING new PB-BUFFER (a saved-data file begun by the caller: root compound and the open compound `data`), suffix
*> (PIC X(128)): closes `data`, writes DataVersion 5023 and the root, and writes the gzip file (07 §10.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SUFFIX               PIC X(128).
 PROCEDURE DIVISION USING PB-BUFFER L-SUFFIX.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "DataVersion" TO WN
     MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-PATH" USING L-SUFFIX WS-PATH WS-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-LENGTH PB-BUFFER
     GOBACK.
 END PROGRAM VFMT-SAVED-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VFMT-SAVED-BEGIN.
*> USING new PB-BUFFER: resets it and writes the file root and the compound `data` (07 §10.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "data" TO WN
     MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     GOBACK.
 END PROGRAM VFMT-SAVED-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VANILLA-SAVED-WRITE.
*> No parameters: writes data/minecraft/weather.dat (07 §10.4.1), world_clocks.dat (§10.4.2: the overworld clock, total_ticks =
*> CW-CLOCK-BASE + CW-TIME, the other clocks as they were) and game_rules.dat (§10.4.3: the rules that are not at
*> their default, keys with minecraft:, the rules the core does not know as they were). The folders are made when absent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRULES.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-OWNED               PIC X(512).
 01 WS-KEY-DATA            PIC X(16) VALUE "data".
 01 WS-SUFFIX              PIC X(128).
 01 WS-NAME                PIC X(128).
 01 WS-INT                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE "/data" TO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-LENGTH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE "/data/minecraft" TO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-LENGTH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE 0 TO RETURN-CODE
*>   weather.dat
     MOVE "/data/minecraft/weather.dat" TO WS-SUFFIX
     CALL "VFMT-OPEN-OLD" USING WS-SUFFIX WS-KEY-DATA PB-BUFFER WS-FOUND
     CALL "VFMT-SAVED-BEGIN" USING WK-BUFFER
     MOVE "clear_weather_time" TO WN MOVE 18 TO WL
     CALL "NBT-WRITE-INT" USING WK-BUFFER WN WL CW-CLEAR-TIME
     MOVE "rain_time" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-INT" USING WK-BUFFER WN WL CW-RAIN-TIME
     MOVE "thunder_time" TO WN MOVE 12 TO WL
     CALL "NBT-WRITE-INT" USING WK-BUFFER WN WL CW-THUNDER-TIME
     MOVE "raining" TO WN MOVE 7 TO WL
     MOVE CW-RAINING TO WS-INT
     CALL "NBT-WRITE-BYTE" USING WK-BUFFER WN WL WS-INT
     MOVE "thundering" TO WN MOVE 10 TO WL
     MOVE CW-THUNDERING TO WS-INT
     CALL "NBT-WRITE-BYTE" USING WK-BUFFER WN WL WS-INT
     MOVE "|clear_weather_time|rain_time|thunder_time|raining|thundering|" TO WS-OWNED
     MOVE 0 TO WS-MODE
     CALL "VFMT-COPY-OTHERS" USING PB-BUFFER WK-BUFFER WS-OWNED WS-MODE WS-FOUND
     CALL "VFMT-SAVED-END" USING WK-BUFFER WS-SUFFIX
*>   world_clocks.dat
     MOVE "/data/minecraft/world_clocks.dat" TO WS-SUFFIX
     CALL "VFMT-OPEN-OLD" USING WS-SUFFIX WS-KEY-DATA PB-BUFFER WS-FOUND
     CALL "VFMT-SAVED-BEGIN" USING WK-BUFFER
     MOVE "minecraft:overworld" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING WK-BUFFER WN WL
     MOVE "total_ticks" TO WN MOVE 11 TO WL
     COMPUTE WS-LONG = CW-CLOCK-BASE + CW-TIME
     CALL "NBT-WRITE-LONG" USING WK-BUFFER WN WL WS-LONG
     MOVE "partial_tick" TO WN MOVE 12 TO WL
     MOVE 0 TO WS-FLOAT
     CALL "NBT-WRITE-FLOAT" USING WK-BUFFER WN WL WS-FLOAT
     MOVE "rate" TO WN MOVE 4 TO WL
     MOVE 1 TO WS-FLOAT
     CALL "NBT-WRITE-FLOAT" USING WK-BUFFER WN WL WS-FLOAT
     MOVE "paused" TO WN MOVE 6 TO WL
     MOVE 0 TO WS-INT
     CALL "NBT-WRITE-BYTE" USING WK-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING WK-BUFFER
     MOVE "|minecraft:overworld|" TO WS-OWNED
     MOVE 0 TO WS-MODE
     CALL "VFMT-COPY-OTHERS" USING PB-BUFFER WK-BUFFER WS-OWNED WS-MODE WS-FOUND
     CALL "VFMT-SAVED-END" USING WK-BUFFER WS-SUFFIX
*>   game_rules.dat
     MOVE "/data/minecraft/game_rules.dat" TO WS-SUFFIX
     MOVE "advance_time" TO WS-NAME
     CALL "BR-RULE-FIND" USING WS-NAME WS-I
     CALL "VFMT-OPEN-OLD" USING WS-SUFFIX WS-KEY-DATA PB-BUFFER WS-FOUND
     CALL "VFMT-SAVED-BEGIN" USING WK-BUFFER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GR-COUNT
         IF GR-VALUE(WS-I) NOT = GR-D-VALUE(WS-I)
             MOVE SPACES TO WN
             STRING "minecraft:" FUNCTION TRIM(GR-D-NAME(WS-I)) DELIMITED BY SIZE INTO WN
             COMPUTE WL = 10 + FUNCTION LENGTH(FUNCTION TRIM(GR-D-NAME(WS-I)))
             MOVE GR-VALUE(WS-I) TO WS-INT
             IF GR-D-TYPE(WS-I) = "B"
                 CALL "NBT-WRITE-BYTE" USING WK-BUFFER WN WL WS-INT
             ELSE
                 CALL "NBT-WRITE-INT" USING WK-BUFFER WN WL WS-INT
             END-IF
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-OWNED
     MOVE 1 TO WS-MODE
     CALL "VFMT-COPY-OTHERS" USING PB-BUFFER WK-BUFFER WS-OWNED WS-MODE WS-FOUND
     CALL "VFMT-SAVED-END" USING WK-BUFFER WS-SUFFIX
     GOBACK.
 END PROGRAM VANILLA-SAVED-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VANILLA-LEVEL-WRITE.
*> No parameters: saves a level.dat of the 26.3 layout (07 §10.2). The file as it was becomes level.dat_old; the new
*> level.dat has the keys the core owns (DataVersion, GameType, spawn, Time = CW-GAME-TIME + CW-TICKS, LastPlayed,
*> LevelName) and every other child of `Data` as it was; then the saved-data files (VANILLA-SAVED-WRITE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-KEY-DATA            PIC X(16) VALUE "Data".
 01 WS-SUFFIX              PIC X(128).
 01 WS-OWNED               PIC X(512)
    VALUE "|DataVersion|GameType|spawn|Time|LastPlayed|LevelName|".
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-INT                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-POS-INTS.
    05 WS-POS-INT          BINARY-LONG OCCURS 3 TIMES.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE "/level.dat" TO WS-SUFFIX
     CALL "VFMT-OPEN-OLD" USING WS-SUFFIX WS-KEY-DATA PB-BUFFER WS-FOUND
     IF WS-FOUND = 1
         MOVE "/level.dat_old" TO WS-SUFFIX
         CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-LENGTH
         MOVE PB-POS TO WS-INT
         CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-LENGTH PB-BUFFER
         MOVE WS-INT TO PB-POS
     END-IF
     CALL "PB-RESET" USING WK-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING WK-BUFFER WN WL
     MOVE "Data" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING WK-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING WK-BUFFER WN WL WS-DATA-VERSION
     MOVE "GameType" TO WN MOVE 8 TO WL
     MOVE CW-GAME-MODE TO WS-INT
     CALL "NBT-WRITE-INT" USING WK-BUFFER WN WL WS-INT
     MOVE "spawn" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING WK-BUFFER WN WL
     MOVE "dimension" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-STRING" USING WK-BUFFER WN WL DM-KEY(CW-DIM(1)) DM-KEY-LENGTH(CW-DIM(1))
     COMPUTE WS-POS-INT(1) = FUNCTION INTEGER(CW-SPAWN-X)
     COMPUTE WS-POS-INT(2) = FUNCTION INTEGER(CW-SPAWN-Y)
     COMPUTE WS-POS-INT(3) = FUNCTION INTEGER(CW-SPAWN-Z)
     MOVE "pos" TO WN MOVE 3 TO WL
     CALL "NBT-WRITE-INT-ARRAY" USING WK-BUFFER WN WL WS-THREE WS-POS-INTS
     MOVE "yaw" TO WN MOVE 3 TO WL
     CALL "NBT-WRITE-FLOAT" USING WK-BUFFER WN WL CW-SPAWN-YAW
     MOVE "pitch" TO WN MOVE 5 TO WL
     MOVE 0 TO WS-FLOAT
     CALL "NBT-WRITE-FLOAT" USING WK-BUFFER WN WL WS-FLOAT
     CALL "NBT-WRITE-COMPOUND-END" USING WK-BUFFER
     MOVE "Time" TO WN MOVE 4 TO WL
     COMPUTE WS-LONG = CW-GAME-TIME + CW-TICKS
     CALL "NBT-WRITE-LONG" USING WK-BUFFER WN WL WS-LONG
     MOVE "LastPlayed" TO WN MOVE 10 TO WL
     CALL "VFMT-EPOCH-MS" USING WS-LONG
     CALL "NBT-WRITE-LONG" USING WK-BUFFER WN WL WS-LONG
     MOVE "LevelName" TO WN MOVE 9 TO WL
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CW-NAME TRAILING)) TO WS-INT
     IF CW-NAME = SPACES
         MOVE 0 TO WS-INT
     END-IF
     CALL "NBT-WRITE-STRING" USING WK-BUFFER WN WL CW-NAME WS-INT
     CALL "VFMT-COPY-OTHERS" USING PB-BUFFER WK-BUFFER WS-OWNED WS-MODE WS-FOUND
     CALL "NBT-WRITE-COMPOUND-END" USING WK-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING WK-BUFFER
     MOVE "/level.dat" TO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-LENGTH WK-BUFFER
     CALL "VANILLA-SAVED-WRITE"
     GOBACK.
 END PROGRAM VANILLA-LEVEL-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VANILLA-SAVED-READ.
*> USING has-clock out (BINARY-LONG), clock ticks out (BINARY-DOUBLE: total_ticks of minecraft:overworld), has-weather
*> out (BINARY-LONG): reads data/minecraft/weather.dat into CW-CLEAR-TIME .. CW-THUNDERING (07 §10.4.1), world_clocks.dat
*> (§10.4.2: the overworld clock; CW-CLOCK-BASE is its whole days) and game_rules.dat (§10.4.3: keys with minecraft:, a
*> Byte or an Int, rules the core does not know are skipped). A missing file or member changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRULES.
 COPY RULES.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY-DATA            PIC X(16) VALUE "data".
 01 WS-SUFFIX              PIC X(128).
 01 WS-INT                 BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-RULE                PIC X(40).
 01 WS-INDEX               BINARY-LONG.
 01 WS-QUOTIENT            BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-HAS-CLOCK            BINARY-LONG.
 01 L-TICKS                BINARY-DOUBLE.
 01 L-HAS-WEATHER          BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS-CLOCK L-TICKS L-HAS-WEATHER.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO L-HAS-CLOCK L-HAS-WEATHER
     MOVE "/data/minecraft/weather.dat" TO WS-SUFFIX
     CALL "VFMT-OPEN-OLD" USING WS-SUFFIX WS-KEY-DATA PB-BUFFER WS-FOUND
     PERFORM UNTIL WS-FOUND = 0 OR PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "clear_weather_time" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER CW-CLEAR-TIME
                 MOVE 1 TO L-HAS-WEATHER
             WHEN WN = "rain_time" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER CW-RAIN-TIME
             WHEN WN = "thunder_time" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER CW-THUNDER-TIME
             WHEN WN = "raining" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                 MOVE 0 TO CW-RAINING
                 IF WS-INT NOT = 0
                     MOVE 1 TO CW-RAINING
                 END-IF
             WHEN WN = "thundering" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                 MOVE 0 TO CW-THUNDERING
                 IF WS-INT NOT = 0
                     MOVE 1 TO CW-THUNDERING
                 END-IF
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     MOVE "/data/minecraft/world_clocks.dat" TO WS-SUFFIX
     CALL "VFMT-OPEN-OLD" USING WS-SUFFIX WS-KEY-DATA PB-BUFFER WS-FOUND
     PERFORM UNTIL WS-FOUND = 0 OR PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "minecraft:overworld" AND WS-TYPE = 10
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-NAME-CAPACITY WL
                 IF WS-INNER-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 IF WN = "total_ticks" AND WS-INNER-TYPE = 4
                     CALL "PB-GET-LONG" USING PB-BUFFER L-TICKS
                     MOVE 1 TO L-HAS-CLOCK
                     COMPUTE WS-QUOTIENT = L-TICKS / RULE-DAY-LENGTH
                     COMPUTE CW-CLOCK-BASE = WS-QUOTIENT * RULE-DAY-LENGTH
                 ELSE
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                 END-IF
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     MOVE "/data/minecraft/game_rules.dat" TO WS-SUFFIX
     CALL "VFMT-OPEN-OLD" USING WS-SUFFIX WS-KEY-DATA PB-BUFFER WS-FOUND
     PERFORM UNTIL WS-FOUND = 0 OR PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         MOVE 0 TO WS-INDEX
         IF WL > 10 AND WL <= 50 AND WN(1:10) = "minecraft:"
             MOVE SPACES TO WS-RULE
             MOVE WN(11:WL - 10) TO WS-RULE
             CALL "BR-RULE-FIND" USING WS-RULE WS-INDEX
         END-IF
         EVALUATE TRUE
             WHEN WS-INDEX > 0 AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                 MOVE 0 TO WS-VALUE
                 IF WS-INT NOT = 0
                     MOVE 1 TO WS-VALUE
                 END-IF
                 CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
             WHEN WS-INDEX > 0 AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                 MOVE WS-INT TO WS-VALUE
                 CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM VANILLA-SAVED-READ.
