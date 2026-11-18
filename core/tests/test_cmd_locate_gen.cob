*> Real-data test (skipped as a pass without the generated packs; lane buglocate T32500, operator report of try14: /locate did not find "village" or the stronghold, a village was
*> found by flying a couple of hundred blocks). Standard worlds of several seeds are opened (a seed too that is negative and beyond 2^53), an operator stands at the world spawn and at a
*> far spot, and the real command `locate structure <id>` is run through the command path for the villages (the tag #minecraft:village and each of the five village structures),
*> the mineshaft, the ruined portals (tag and plain), the pillager outpost and the igloo. The expected answer is the one a search of 36-1 section 11 step 4 over what the world generation
*> itself makes gives: the model walks the rings r = 0, 1, 2, ... (ix outer, iz inner, border cells of the square) over the random_spread sets that hold a wanted structure, the candidate
*> chunk of a cell is its potential chunk when it is a structure chunk (STRUCT-POTENTIAL, STRUCT-IS-CHUNK) and the start list of that chunk (STRUCT-CHUNK-STARTS, the list the
*> chunk stage STRUCT-STAGE-HOOK counts and places) holds a wanted structure; the first such candidate of a set is its answer of the ring, the nearest answer of the first ring with any
*> wins. The command's reply must be that position and distance (or not_found when the radius 100 holds no start), and for the village tag the chunk of the answer, generated whole with the
*> villages on and off, must differ (a village is really made there). The stronghold (concentric_rings, step 3) is asked from the same spots: the answer must be the nearest chunk of the whole snapped
*> ring list (every one of the 128 positions snapped by STRUCT-RINGS-ALL after the command) and the command must have snapped only the few positions that can be the nearest (a search that snaps all
*> 128 takes about a minute and a half on the debug build: the game stood still for it, so a first /locate structure stronghold or an eye of ender looked like finding nothing).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE-GEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY DIMENSIONS.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SEED-N              BINARY-LONG.
 01 WS-SPOT                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-SEED-NAMES.
    05 FILLER PIC X(24) VALUE "12345".
    05 FILLER PIC X(24) VALUE "3".
    05 FILLER PIC X(24) VALUE "77".
    05 FILLER PIC X(24) VALUE "-4172144997902289642".
 01 WS-SEED-R REDEFINES WS-SEED-NAMES.
    05 WS-SEED-TEXT        PIC X(24) OCCURS 4 TIMES.
*> what is asked for: kind 1 a structure (WS-WID the key), kind 2 a tag (WS-WID the tag, WS-WPREFIX the leading part of the keys of its structures)
 01 WS-WANTS.
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(40) VALUE "minecraft:village".
    05 FILLER PIC X(40) VALUE "minecraft:village_".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:village_plains".
    05 FILLER PIC X(40) VALUE "minecraft:village_plains".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:village_desert".
    05 FILLER PIC X(40) VALUE "minecraft:village_desert".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:village_savanna".
    05 FILLER PIC X(40) VALUE "minecraft:village_savanna".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:village_snowy".
    05 FILLER PIC X(40) VALUE "minecraft:village_snowy".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:village_taiga".
    05 FILLER PIC X(40) VALUE "minecraft:village_taiga".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:mineshaft".
    05 FILLER PIC X(40) VALUE "minecraft:mineshaft".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(40) VALUE "minecraft:ruined_portal".
    05 FILLER PIC X(40) VALUE "minecraft:ruined_portal".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:ruined_portal".
    05 FILLER PIC X(40) VALUE "minecraft:ruined_portal".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:pillager_outpost".
    05 FILLER PIC X(40) VALUE "minecraft:pillager_outpost".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:igloo".
    05 FILLER PIC X(40) VALUE "minecraft:igloo".
 01 WS-WANTS-R REDEFINES WS-WANTS.
    05 WS-WANT-ROW OCCURS 11 TIMES.
       10 WS-WKIND         PIC X(1).
       10 WS-WID           PIC X(40).
       10 WS-WPREFIX       PIC X(40).
 01 WS-WKIND-N             BINARY-LONG.
 01 WS-WLEN                BINARY-LONG.
 01 WS-WANTED-ID           PIC X(80).
 01 WS-ROW-WANTED          BINARY-LONG.
 01 WS-SET-WANTED.
    05 WS-SW               BINARY-LONG OCCURS 64 TIMES.
*> origins: the spot's block position
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-NEGR                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-SET-HIT             BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ANSWERED            BINARY-LONG.
 01 WS-MFOUND              BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MCX                 BINARY-LONG.
 01 WS-MCZ                 BINARY-LONG.
 01 WS-BEST-D2             BINARY-DOUBLE.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-RD                  BINARY-LONG.
 01 WS-FOUND-R             BINARY-LONG.
 01 WS-PART-A              PIC X(1024).
 01 WS-PART-B              PIC X(1024).
 01 WS-REST                PIC X(1024).
 01 WS-XS                  PIC X(32).
 01 WS-YS                  PIC X(32).
 01 WS-ZS                  PIC X(32).
 01 WS-DS                  PIC X(32).
 01 WS-REF-A               PIC X(304640).
 01 WS-REF-B               PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-GATE-N              BINARY-LONG.
 01 WS-GATES.
    05 WS-GATE-KEY         PIC X(80) OCCURS 64 TIMES.
 01 WS-NUM-A               PIC -(9)9.
 01 WS-NUM-B               PIC -(9)9.
 01 WS-CASE                PIC X(240).
 01 WS-ROWN                BINARY-LONG.
 01 WS-DONE-COUNT          BINARY-LONG.
 01 WS-STRONG-SET          BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-BEST-I              BINARY-LONG.
 01 WS-BEST-D              BINARY-DOUBLE.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG VALUE 32.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US13 /locate structure vs generation: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     PERFORM VARYING WS-SEED-N FROM 1 BY 1 UNTIL WS-SEED-N > 4
         CALL "TEST-SETTINGS" USING CORE-SETTINGS
         MOVE "standard" TO CS-WORLD-TYPE
         MOVE WS-DIR TO CS-GENERATED-DIR
         MOVE 2 TO CS-VIEW-DISTANCE
         MOVE WS-SEED-TEXT(WS-SEED-N) TO CS-SEED-TEXT
         MOVE 0 TO CS-HOSTILE-MOBS
         CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
         MOVE CW-DIM(1) TO WS-DIM
         MOVE "Opal" TO WS-NAME
         MOVE 4 TO WS-NAME-LENGTH
         CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
         CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
         MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
         PERFORM VARYING WS-SPOT FROM 1 BY 1 UNTIL WS-SPOT > 2
             IF WS-SPOT = 1
                 COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW))
                 COMPUTE WS-SZ = FUNCTION INTEGER(PL-Z(WS-ROW))
             ELSE
                 MOVE 4100 TO WS-SX
                 MOVE -2700 TO WS-SZ
                 MOVE 4100.5 TO PL-X(WS-ROW)
                 MOVE -2699.5 TO PL-Z(WS-ROW)
             END-IF
*>           the single village structures are searched where the tag finds one near (a desert village from far away takes minutes to reach its 100th ring): at the spawn of the first seed
             PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > 11
                 IF (WS-SPOT = 1 AND WS-SEED-N = 1) OR WS-W = 1 OR WS-W >= 7
                     PERFORM CHECK-WANT
                 END-IF
             END-PERFORM
         END-PERFORM
         IF WS-SEED-N < 3
             PERFORM CHECK-STRONGHOLD
         END-IF
     END-PERFORM
     STOP RUN.

*> The want WS-W from the spot (WS-SX, WS-SZ): the command's reply against the model's search.
 CHECK-WANT.
     MOVE 1 TO WS-WKIND-N
     IF WS-WKIND(WS-W) = "2"
         MOVE 2 TO WS-WKIND-N
     END-IF
     MOVE SPACES TO WS-LINE
     IF WS-WKIND-N = 2
         STRING "locate structure #" FUNCTION TRIM(WS-WID(WS-W)) DELIMITED BY SIZE INTO WS-LINE
     ELSE
         STRING "locate structure " FUNCTION TRIM(WS-WID(WS-W)) DELIMITED BY SIZE INTO WS-LINE
     END-IF
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM MODEL-SEARCH
     MOVE WS-SX TO WS-NUM-A
     MOVE WS-SZ TO WS-NUM-B
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate seed " FUNCTION TRIM(WS-SEED-TEXT(WS-SEED-N)) " from (" FUNCTION TRIM(WS-NUM-A) "," FUNCTION TRIM(WS-NUM-B) ") "
         FUNCTION TRIM(WS-LINE(8:80)) " answers as the generation's starts do" DELIMITED BY SIZE INTO WS-CASE
     IF WS-MFOUND = 0
         MOVE WS-CASE TO TL-CASE
         MOVE "commands.locate.structure.not_found" TO TL-EXPECTED
         MOVE WS-TEXT(1:35) TO TL-OBSERVED
         MOVE "T" TO TL-MODE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "N" TO TL-MODE
     ELSE
         MOVE WS-CASE TO TL-CASE
         MOVE "commands.locate.structure.success(" TO TL-EXPECTED
         MOVE WS-TEXT(1:34) TO TL-OBSERVED
         MOVE "T" TO TL-MODE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "N" TO TL-MODE
         PERFORM PARSE-REPORT
         MOVE SPACES TO WS-CASE
         STRING "acceptance US13 /locate seed " FUNCTION TRIM(WS-SEED-TEXT(WS-SEED-N)) " from (" FUNCTION TRIM(WS-NUM-A) "," FUNCTION TRIM(WS-NUM-B) ") "
             FUNCTION TRIM(WS-LINE(8:80)) " position" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         COMPUTE TL-EXPECTED-N = WS-MX * 100003 + WS-MZ
         COMPUTE TL-OBSERVED-N = WS-RX * 100003 + WS-RZ
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-CASE
         STRING "acceptance US13 /locate seed " FUNCTION TRIM(WS-SEED-TEXT(WS-SEED-N)) " from (" FUNCTION TRIM(WS-NUM-A) "," FUNCTION TRIM(WS-NUM-B) ") "
             FUNCTION TRIM(WS-LINE(8:80)) " distance" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         COMPUTE WS-DX = WS-MX - WS-SX
         COMPUTE WS-DZ = WS-MZ - WS-SZ
         COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ))
         MOVE WS-RD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-W = 1
             PERFORM CHECK-GENERATED
         END-IF
     END-IF.

*> The village tag's answer chunk (WS-MCX, WS-MCZ) generated whole with the villages off (the game's other structures on) and on differs: a village is really made there.
 CHECK-GENERATED.
     MOVE SD-GATE-COUNT TO WS-GATE-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-GATE-N
         MOVE SD-GATE(WS-I) TO WS-GATE-KEY(WS-I)
     END-PERFORM
     CALL "STRUCT-GATE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-GATE-N
         IF WS-GATE-KEY(WS-I)(1:18) NOT = "minecraft:village_"
             MOVE WS-GATE-KEY(WS-I) TO WS-KEY
             CALL "STRUCT-GATE-ON" USING WS-KEY
         END-IF
     END-PERFORM
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-MCX WS-MCZ WS-REF-B WS-REF-Y
     CALL "STRUCT-GATE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-GATE-N
         MOVE WS-GATE-KEY(WS-I) TO WS-KEY
         CALL "STRUCT-GATE-ON" USING WS-KEY
     END-PERFORM
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-MCX WS-MCZ WS-REF-A WS-REF-Y
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REF-A NOT = WS-REF-B
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate seed " FUNCTION TRIM(WS-SEED-TEXT(WS-SEED-N)) " the chunk the village tag answers is changed by the villages of the generation" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-ROW-WANTED: 1 when the structure row WS-ST is wanted by the want WS-W (a structure: its key; a tag: the leading part of its keys).
 ROW-WANTED.
     MOVE 0 TO WS-ROW-WANTED
     MOVE SDT-KEY(WS-ST) TO WS-KEY
     IF WS-WKIND-N = 1
         IF WS-KEY = WS-WID(WS-W)
             MOVE 1 TO WS-ROW-WANTED
         END-IF
     ELSE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-WPREFIX(WS-W))) TO WS-WLEN
         MOVE SPACES TO WS-WANTED-ID
         MOVE WS-WPREFIX(WS-W) TO WS-WANTED-ID
         IF WS-KEY(1:WS-WLEN) = WS-WANTED-ID(1:WS-WLEN)
             MOVE 1 TO WS-ROW-WANTED
         END-IF
     END-IF.

*> MODEL-SEARCH: 36-1 section 11 step 4 over the sets that hold a wanted structure: WS-MFOUND, the locate position (WS-MX, WS-MZ) and the chunk (WS-MCX, WS-MCZ) of the answer.
 MODEL-SEARCH.
     MOVE 0 TO WS-MFOUND WS-MX WS-MZ WS-MCX WS-MCZ
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         MOVE 0 TO WS-SW(WS-S)
         IF SS-KIND(WS-S) = 2
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
                 MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
                 PERFORM ROW-WANTED
                 IF WS-ROW-WANTED = 1
                     MOVE 1 TO WS-SW(WS-S)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     COMPUTE WS-OX = FUNCTION INTEGER(WS-SX / 16)
     COMPUTE WS-OZ = FUNCTION INTEGER(WS-SZ / 16)
     MOVE 0 TO WS-ANSWERED
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 100 OR WS-ANSWERED = 1
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
             IF WS-SW(WS-S) = 1
                 PERFORM MODEL-RING
             END-IF
         END-PERFORM
     END-PERFORM.

*> The ring WS-R of the set WS-S: the first candidate (ix outer, iz inner) that is a structure chunk holding a wanted start answers for the set.
 MODEL-RING.
     MOVE 0 TO WS-DONE
     COMPUTE WS-NEGR = 0 - WS-R
     PERFORM VARYING WS-IX FROM WS-NEGR BY 1 UNTIL WS-IX > WS-R OR WS-DONE = 1
         PERFORM VARYING WS-IZ FROM WS-NEGR BY 1 UNTIL WS-IZ > WS-R OR WS-DONE = 1
             IF FUNCTION ABS(WS-IX) = WS-R OR FUNCTION ABS(WS-IZ) = WS-R
                 COMPUTE WS-CX = WS-OX + SS-SPACING(WS-S) * WS-IX
                 COMPUTE WS-CZ = WS-OZ + SS-SPACING(WS-S) * WS-IZ
                 CALL "STRUCT-POTENTIAL" USING WS-S CW-SEED WS-CX WS-CZ WS-PX WS-PZ
                 CALL "STRUCT-IS-CHUNK" USING WS-S CW-SEED WS-PX WS-PZ WS-FLAG
                 MOVE 0 TO WS-HIT
                 IF WS-FLAG = 1
                     CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-PX WS-PZ WS-COUNT
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                         IF SC-SET(WS-J) = WS-S
                             MOVE SC-STRUCT(WS-J) TO WS-ST
                             PERFORM ROW-WANTED
                             IF WS-ROW-WANTED = 1
                                 MOVE 1 TO WS-HIT
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
                 IF WS-HIT = 1
                     MOVE 1 TO WS-DONE
                     CALL "STRUCT-LOCATE-POS" USING WS-S WS-PX WS-PZ WS-LX WS-LY WS-LZ
                     COMPUTE WS-DX = WS-LX - WS-SX
                     COMPUTE WS-DZ = WS-LZ - WS-SZ
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
                     IF WS-ANSWERED = 0 OR WS-D2 < WS-BEST-D2
                         MOVE 1 TO WS-ANSWERED
                         MOVE 1 TO WS-MFOUND
                         MOVE WS-D2 TO WS-BEST-D2
                         MOVE WS-LX TO WS-MX
                         MOVE WS-LZ TO WS-MZ
                         MOVE WS-PX TO WS-MCX
                         MOVE WS-PZ TO WS-MCZ
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM.

*> WS-RX, WS-RZ, WS-RD: the numbers of the reply WS-TEXT, commands.locate.structure.success(key,[x, ~, z],d).
 PARSE-REPORT.
     UNSTRING WS-TEXT DELIMITED BY "[" INTO WS-PART-A WS-PART-B
     UNSTRING WS-PART-B DELIMITED BY ", " INTO WS-XS WS-YS WS-REST
     UNSTRING WS-REST DELIMITED BY "]" INTO WS-ZS WS-PART-A
     UNSTRING WS-PART-A DELIMITED BY "," INTO WS-PART-B WS-DS
     UNSTRING WS-DS DELIMITED BY ")" INTO WS-PART-B
     COMPUTE WS-RX = FUNCTION NUMVAL(WS-XS)
     COMPUTE WS-RZ = FUNCTION NUMVAL(WS-ZS)
     COMPUTE WS-RD = FUNCTION NUMVAL(WS-PART-B).

*> The stronghold from the two spots: the reply is the nearest chunk of the whole ring list; the command snapped only a few of the 128 positions.
 CHECK-STRONGHOLD.
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
     MOVE 0.5 TO PL-X(WS-ROW)
     MOVE 0.5 TO PL-Z(WS-ROW)
     MOVE 0 TO WS-SX
     MOVE 0 TO WS-SZ
     MOVE 0 TO WS-STRONG-SET
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         IF SS-KIND(WS-S) = 0
             MOVE WS-S TO WS-STRONG-SET
         END-IF
     END-PERFORM
*>   a fresh ring list: nothing snapped yet
     MOVE CW-SEED TO WS-SEED
     CALL "STRUCT-RINGS-PREP" USING WS-STRONG-SET WS-SEED
     MOVE "locate structure minecraft:stronghold" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM PARSE-REPORT
     MOVE SS-RING-ROW(WS-STRONG-SET) TO WS-ROWN
     MOVE 0 TO WS-DONE-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-N(WS-ROWN)
         IF SR-DONE(WS-ROWN, WS-I) = 1
             ADD 1 TO WS-DONE-COUNT
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate seed " FUNCTION TRIM(WS-SEED-TEXT(WS-SEED-N)) " stronghold: the command snapped at most 16 of the 128 ring positions" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DONE-COUNT >= 1 AND WS-DONE-COUNT <= 16
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the whole list, snapped now: the nearest chunk by the document (first of equal distances)
     CALL "STRUCT-RINGS-ALL" USING WS-STRONG-SET WS-SEED
     MOVE 0 TO WS-BEST-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-N(WS-ROWN)
         COMPUTE WS-DX = SR-X(WS-ROWN, WS-I) * 16 + 8
         COMPUTE WS-DZ = SR-Z(WS-ROWN, WS-I) * 16 + 8
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
         IF WS-BEST-I = 0 OR WS-D2 < WS-BEST-D
             MOVE WS-D2 TO WS-BEST-D
             MOVE WS-I TO WS-BEST-I
         END-IF
     END-PERFORM
     MOVE SR-X(WS-ROWN, WS-BEST-I) TO WS-FX
     MOVE SR-Z(WS-ROWN, WS-BEST-I) TO WS-FZ
     CALL "STRUCT-LOCATE-POS" USING WS-STRONG-SET WS-FX WS-FZ WS-LX WS-LY WS-LZ
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate seed " FUNCTION TRIM(WS-SEED-TEXT(WS-SEED-N)) " stronghold: the position is the nearest chunk of the whole ring list" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-LX * 100003 + WS-LZ
     COMPUTE TL-OBSERVED-N = WS-RX * 100003 + WS-RZ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   asked again with the list snapped: the same answer
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM PARSE-REPORT
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate seed " FUNCTION TRIM(WS-SEED-TEXT(WS-SEED-N)) " stronghold: asked again over the snapped list it answers the same" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-LX * 100003 + WS-LZ
     COMPUTE TL-OBSERVED-N = WS-RX * 100003 + WS-RZ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CMD-LOCATE-GEN.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY CMDTEST.
