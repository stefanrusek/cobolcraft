*> Implementation test of the saved stronghold piece keys (docs/protocol/36-structures-5-mineshaft-stronghold.md section 3.9; core/src/struct-piece-keys.cob, struct-start.cob, struct-start-nbt.cob, struct-sh-place.cob):
*> every stronghold piece id (shcc, shfc, sh5c, shlt, shli, shpr, shph, shrt, shrc, shsd, shstart, shs, shssd) is written with EntryDoor as the SmallDoorType constant name (OPENING, WOOD_DOOR, GRATES, IRON_DOOR)
*> and the keys of its row of the table (Left, Right, Chest, Steps, leftLow, leftHigh, rightLow, rightHigh, Tall, Mob, Type, Source) from the builder's door and type fields, a written compound loads back into the
*> same pieces, a piece without EntryDoor or with an EntryDoor that is not a constant name (lower case, an int) does not load, a missing key reads 0, and the placement sets the saved flags: the chest corridor's Chest
*> once its chest is made inside the write box and the portal room's Mob once its spawner is. The builder is filled by hand with the values of the document; the flags are set by the real placement code.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-3-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY STRUCTPIECE.
 COPY STRUCTSH.
 COPY STRUCTBLK.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BR                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-BT                  BINARY-LONG.
 01 WS-BO                  BINARY-LONG VALUE 2.
 01 WS-BD                  BINARY-LONG VALUE 2.
 01 WS-MST                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-BB.
    05 WS-BB-N             BINARY-LONG OCCURS 6 TIMES.
 01 WS-VALUE               BINARY-LONG.
 01 WS-STR                 PIC X(64).
 01 WS-STRLEN              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PAD                 PIC 99.
 01 WS-PID                 PIC X(32).
 01 WS-PIDLEN              BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-BEFORES.
    05 WS-BEFORE           PIC X(1024) OCCURS 13 TIMES.
 01 WS-TABLE-DATA.
    05 FILLER              PIC X(120) VALUE "30shs     11000EntryDoor:WOOD_DOOR,Left:1,Right:0                                                                       ".
    05 FILLER              PIC X(120) VALUE "19shcc    01000EntryDoor:OPENING,Chest:1                                                                                ".
    05 FILLER              PIC X(120) VALUE "20shfc    23000EntryDoor:GRATES,Steps:3                                                                                 ".
    05 FILLER              PIC X(120) VALUE "21sh5c    31011EntryDoor:IRON_DOOR,leftLow:1,leftHigh:0,rightLow:1,rightHigh:1                                          ".
    05 FILLER              PIC X(120) VALUE "22shlt    10000EntryDoor:WOOD_DOOR                                                                                      ".
    05 FILLER              PIC X(120) VALUE "23shli    21000EntryDoor:GRATES,Tall:1                                                                                  ".
    05 FILLER              PIC X(120) VALUE "24shpr    31000EntryDoor:IRON_DOOR,Mob:1                                                                                ".
    05 FILLER              PIC X(120) VALUE "25shph    00000EntryDoor:OPENING                                                                                        ".
    05 FILLER              PIC X(120) VALUE "26shrt    10000EntryDoor:WOOD_DOOR                                                                                      ".
    05 FILLER              PIC X(120) VALUE "27shrc    22000EntryDoor:GRATES,Type:2                                                                                  ".
    05 FILLER              PIC X(120) VALUE "28shsd    30000EntryDoor:IRON_DOOR,Source:0                                                                             ".
    05 FILLER              PIC X(120) VALUE "29shstart 11000EntryDoor:WOOD_DOOR,Source:1                                                                             ".
    05 FILLER              PIC X(120) VALUE "31shssd   00000EntryDoor:OPENING                                                                                        ".
 01 WS-TABLE REDEFINES WS-TABLE-DATA.
    05 WS-T OCCURS 13 TIMES.
       10 WT-TYPE          PIC 99.
       10 WT-NAME          PIC X(8).
       10 WT-DOOR          PIC 9.
       10 WT-F2            PIC 9.
       10 WT-F3            PIC 9.
       10 WT-F4            PIC 9.
       10 WT-MST           PIC 9.
       10 WT-TAIL          PIC X(105).
 01 WS-PTR                 USAGE POINTER.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-IDX                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/stronghold_corridor".
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     CALL "MSP-BLOCKS"
     MOVE SBK-S-CAVE-AIR TO WS-AIR
     MOVE 13 TO SD-ST-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         MOVE WS-I TO WS-PAD
         MOVE SPACES TO SDT-KEY(WS-I)
         STRING "minecraft:p" WS-PAD DELIMITED BY SIZE INTO SDT-KEY(WS-I)
         MOVE 0 TO SDT-ADAPT(WS-I)
     END-PERFORM
     CALL "STRUCT-STORE-RESET"

*>   one start per piece id: the builder's door and type fields become the keys
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 13
         CALL "SPB-RESET"
         MOVE WT-TYPE(WS-S) TO WS-BT
         MOVE 0 TO WS-X0 MOVE 40 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 4 TO WS-X1 MOVE 44 TO WS-Y1 MOVE 6 TO WS-Z1
         MOVE WT-MST(WS-S) TO WS-MST
         PERFORM BUILDER-PIECE
         MOVE WT-DOOR(WS-S) TO SP-F1(WS-BR)
         MOVE WT-F2(WS-S) TO SP-F2(WS-BR)
         MOVE WT-F3(WS-S) TO SP-F3(WS-BR)
         MOVE WT-F4(WS-S) TO SP-F4(WS-BR)
         CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-ROW
         PERFORM SET-START-PATH
         PERFORM WRITE-AND-GET
         MOVE SPACES TO TL-EXPECTED
         STRING "{id:minecraft:p" WS-PAD ",ChunkX:0,ChunkZ:0,references:0,Children:[{id:minecraft:"
             FUNCTION TRIM(WT-NAME(WS-S)) ",BB:I[0,40,0,4,44,6],O:2,GD:2,"
             FUNCTION TRIM(WT-TAIL(WS-S)) "}]}" DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-5§3.9 NBT keys by piece: " FUNCTION TRIM(WT-NAME(WS-S)) " is written with " FUNCTION TRIM(WT-TAIL(WS-S))
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK-TEXT
         MOVE TL-OBSERVED TO WS-BEFORE(WS-S)
     END-PERFORM

*>   the thirteen starts load into an empty store and write the same keys
     CALL "STRUCT-STORE-RESET"
     PERFORM READ-STRUCTURES
     MOVE 0 TO WS-SAME
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 13
         PERFORM SET-START-PATH
         PERFORM WRITE-AND-GET
         IF TL-OBSERVED = WS-BEFORE(WS-S)
             ADD 1 TO WS-SAME
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: the thirteen stronghold starts load into an empty store and write the same keys again" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 4 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE SST-FIRST(WS-ROW) TO WS-P
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: the reloaded five crossing holds EntryDoor 3 (IRON_DOOR) and leftLow 1, leftHigh 0, rightLow 1, rightHigh 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-K(WS-P, 1) * 10000 + SPC-K(WS-P, 2) * 1000 + SPC-K(WS-P, 3) * 100 + SPC-K(WS-P, 4) * 10 + SPC-K(WS-P, 5)
     MOVE 31011 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   EntryDoor must be a constant name: absent, lower case and an int make the piece not load (36-5 3.9); a second piece of the same start still loads
     CALL "STRUCT-STORE-RESET"
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:p01" TO WN MOVE 13 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Children" TO WN MOVE 8 TO WL
     MOVE 10 TO WS-VALUE
     MOVE 5 TO WS-N
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-N
     MOVE "minecraft:shs" TO WS-PID MOVE 13 TO WS-PIDLEN
     PERFORM PUT-PIECE-NO-DOOR
     PERFORM PUT-PIECE-DOOR-LOWER
     PERFORM PUT-PIECE-DOOR-INT
     PERFORM PUT-PIECE-DOOR-GOOD
     MOVE "minecraft:shpr" TO WS-PID MOVE 14 TO WS-PIDLEN
     PERFORM PUT-PIECE-DOOR-GOOD
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM READ-STRUCTURES
     MOVE 1 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: of five stronghold pieces, the ones with no EntryDoor, a lower-case wood_door and an int EntryDoor do not load (2 left)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SST-N(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE SST-FIRST(WS-ROW) TO WS-P
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: the loaded straight piece has EntryDoor 1, Left 1, Right 0; keys of other pieces are ignored, a missing Right reads 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-K(WS-P, 1) * 100 + SPC-K(WS-P, 2) * 10 + SPC-K(WS-P, 3)
     MOVE 110 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   the placement sets the saved flags. A chest corridor whose chest is made inside the write box: Chest 1
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 8 TO A-X1 MOVE 44 TO A-Y1 MOVE 8 TO A-Z1
     MOVE 19 TO WS-BT
     PERFORM ADD-WINDOW-PIECE
     MOVE 3 TO WS-X MOVE 41 TO WS-Y MOVE 5 TO WS-Z
     PERFORM SET-AIR
     MOVE 3 TO WS-LX MOVE 1 TO WS-LY MOVE 3 TO WS-LZ
     MOVE SP-F2(WS-BR) TO TL-OBSERVED-N
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: the chest corridor's Chest is 0 before its chest is placed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     CALL "SHP-CHEST" USING WS-BR WS-LX WS-LY WS-LZ WS-LOOT
     MOVE SP-F2(WS-BR) TO TL-OBSERVED-N
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: the chest corridor's Chest is 1 once its chest is made inside the write box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     PERFORM STONE-WORLD
     MOVE 100 TO A-X0 MOVE 40 TO A-Y0 MOVE 100 TO A-Z0 MOVE 108 TO A-X1 MOVE 44 TO A-Y1 MOVE 108 TO A-Z1
     MOVE 19 TO WS-BT
     PERFORM ADD-WINDOW-PIECE
     CALL "SHP-CHEST" USING WS-BR WS-LX WS-LY WS-LZ WS-LOOT
     MOVE SP-F2(WS-BR) TO TL-OBSERVED-N
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: a chest corridor outside the write box keeps Chest 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   another piece type's chest (the library, 23) leaves its own F2 (Tall) alone
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 8 TO A-X1 MOVE 44 TO A-Y1 MOVE 8 TO A-Z1
     MOVE 23 TO WS-BT
     PERFORM ADD-WINDOW-PIECE
     MOVE 3 TO WS-X MOVE 41 TO WS-Y MOVE 5 TO WS-Z
     PERFORM SET-AIR
     CALL "SHP-CHEST" USING WS-BR WS-LX WS-LY WS-LZ WS-LOOT
     MOVE SP-F2(WS-BR) TO TL-OBSERVED-N
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: a library's chest does not set Tall (F2 stays 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   the portal room: Mob 1 once the spawner at local (5,3,6) is inside the write box, 0 for a room outside it
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 10 TO A-X1 MOVE 47 TO A-Y1 MOVE 15 TO A-Z1
     MOVE 24 TO WS-BT
     PERFORM ADD-WINDOW-PIECE
     CALL "SH-POST" USING WS-BR
     MOVE SP-F2(WS-BR) TO TL-OBSERVED-N
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: the portal room's Mob is 1 once its spawner is placed inside the write box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     PERFORM STONE-WORLD
     MOVE 100 TO A-X0 MOVE 40 TO A-Y0 MOVE 100 TO A-Z0 MOVE 110 TO A-X1 MOVE 47 TO A-Y1 MOVE 115 TO A-Z1
     MOVE 24 TO WS-BT
     PERFORM ADD-WINDOW-PIECE
     CALL "SH-POST" USING WS-BR
     MOVE SP-F2(WS-BR) TO TL-OBSERVED-N
     MOVE "acceptance US12 36-5§3.9 NBT keys by piece: a portal room outside the write box keeps Mob 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     STOP RUN.

*> a builder piece of type WS-BT, orientation WS-BO, depth WS-BD and the box WS-X0.. (row in WS-BR)
 BUILDER-PIECE.
     MOVE WS-X0 TO A-X0 MOVE WS-Y0 TO A-Y0 MOVE WS-Z0 TO A-Z0 MOVE WS-X1 TO A-X1 MOVE WS-Y1 TO A-Y1 MOVE WS-Z1 TO A-Z1
     CALL "SPB-ADD" USING WS-BT WS-BO WS-BD WS-MST WS-BOX WS-BR.

 ADD-WINDOW-PIECE.
     MOVE 0 TO WS-MST
     CALL "SPB-ADD" USING WS-BT WS-BO WS-ZERO WS-MST WS-BOX WS-BR.

 STONE-WORLD.
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 135 * 256
         MOVE WS-STONE TO CE-STATE(WS-IDX)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI
     CALL "SH-RESET".

 SET-AIR.
     COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-AIR TO CE-STATE(WS-IDX)
     MOVE 4 TO WS-X
     COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-AIR TO CE-STATE(WS-IDX)
     MOVE 3 TO WS-X
     MOVE 4 TO WS-Z
     COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-AIR TO CE-STATE(WS-IDX)
     MOVE 6 TO WS-Z
     COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-AIR TO CE-STATE(WS-IDX).

*> a piece compound of id WS-STR with a BB and no EntryDoor, and the Left key of a straight piece
 PUT-PIECE-NO-DOOR.
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM PUT-ID-BB
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

 PUT-PIECE-DOOR-LOWER.
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM PUT-ID-BB
     MOVE "EntryDoor" TO WN MOVE 9 TO WL
     MOVE "wood_door" TO WS-STR MOVE 9 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

 PUT-PIECE-DOOR-INT.
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM PUT-ID-BB
     MOVE "EntryDoor" TO WN MOVE 9 TO WL
     MOVE 1 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

 PUT-PIECE-DOOR-GOOD.
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM PUT-ID-BB
     MOVE "EntryDoor" TO WN MOVE 9 TO WL
     MOVE "WOOD_DOOR" TO WS-STR MOVE 9 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     MOVE "Left" TO WN MOVE 4 TO WL
     MOVE 1 TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "Chest" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

 PUT-ID-BB.
     MOVE "id" TO WN MOVE 2 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-PID WS-PIDLEN
     MOVE "BB" TO WN MOVE 2 TO WL
     MOVE 0 TO WS-BB-N(1) WS-BB-N(2) WS-BB-N(3)
     MOVE 1 TO WS-BB-N(4) WS-BB-N(5) WS-BB-N(6)
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB.

 SET-START-PATH.
     MOVE WS-S TO WS-PAD
     MOVE SPACES TO WS-PATH
     STRING "structures.starts.minecraft:p" WS-PAD DELIMITED BY SIZE INTO WS-PATH.

 READ-STRUCTURES.
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE SPACES TO WN
     MOVE 32 TO WS-STRLEN
     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-STRLEN WL
     CALL "STRUCT-STARTS-READ" USING PB-BUFFER WS-CX WS-CZ WS-OUTCOME.

 WRITE-AND-GET.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "STRUCT-STARTS-WRITE" USING PB-BUFFER WS-CX WS-CZ
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED.

 CHECK-TEXT.
     MOVE "A" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STRUCT-36-5-3-9.
 COPY NOSPAWN.
 COPY CORETEST.
