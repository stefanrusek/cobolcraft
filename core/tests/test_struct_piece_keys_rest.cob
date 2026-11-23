*> Implementation test of the saved piece keys of the families beyond 36-4 section 10 and 36-5 section 3.9 (core/src/struct-piece-keys.cob, struct-start.cob, struct-start-nbt.cob, STRUCTPKEYS.cpy):
*> the registry names of the template pieces of the shipwreck (shipwreck), ocean ruin (orp), woodland mansion (wmp) and end city (ecp), so that their starts are not INVALID; the fortress keys of
*> 36-8 section 3.5 (BridgeEndFiller Seed, the two turn pieces' Chest, MonsterThrone Mob); the mineshaft keys of 36-5 sections 2.5, 2.6, 2.11 and 2.12 (hr, sc, hps, Num, tf, D, MST and the room's
*> Entrances list of boxes); the ocean ruin keys of 36-6 section 2.4 (Integrity float, BiomeType WARM or COLD, IsLarge, with Rot and BiomeType required), the shipwreck keys of 36-6 section 4.3 (isBeached,
*> height_adjusted, Rot required), the mansion's short Template name with Rot and Mi (36-7 section 3) and the end city's short Template name with Rot and OW (36-8 section 9). The builder is filled
*> by hand with the values of the documents; a written chunk compound is read back into an empty store and written again, which must give the same text.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-PIECE-KEYS-REST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPROC.
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
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-BT                  BINARY-LONG.
 01 WS-BO                  BINARY-LONG.
 01 WS-BD                  BINARY-LONG.
 01 WS-MST                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STRLEN              BINARY-LONG.
 01 WS-DIGIT               PIC 99.
 01 WS-SAME                BINARY-LONG.
 01 WS-BEFORES.
    05 WS-BEFORE           PIC X(2048) OCCURS 8 TIMES.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-BB.
    05 WS-BB-N             BINARY-LONG OCCURS 6 TIMES.
 01 WS-VALUE               BINARY-LONG.
 01 WS-STR                 PIC X(64).
 01 WS-PID                 PIC X(32).
 01 WS-PIDLEN              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-LOST0               BINARY-LONG.
 01 WS-REFS                BINARY-LONG VALUE 0.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-JIG                 BINARY-LONG VALUE 0.
 01 WS-PROW                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 8 TO SD-ST-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 8
         MOVE WS-S TO WS-DIGIT
         MOVE SPACES TO SDT-KEY(WS-S)
         STRING "minecraft:s" WS-DIGIT DELIMITED BY SIZE INTO SDT-KEY(WS-S)
         MOVE 0 TO SDT-ADAPT(WS-S)
     END-PERFORM
     MOVE 1 TO TP-COUNT
     CALL "STRUCT-STORE-RESET"

*>   the fortress (36-8 3.5): a BridgeEndFiller keeps its Seed, the turn pieces their pending Chest flag (the builder's F2: set when the roll was 0, cleared once the chest is made), the throne its Mob flag
     CALL "SPB-RESET"
     MOVE 5 TO WS-BT MOVE 0 TO WS-BO MOVE 2 TO WS-BD
     MOVE 0 TO WS-X0 MOVE 64 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 4 TO WS-X1 MOVE 70 TO WS-Y1 MOVE 4 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE -123456 TO SP-F1(WS-BR)
     MOVE 11 TO WS-BT MOVE 1 TO WS-BO MOVE 3 TO WS-BD
     MOVE 5 TO WS-X0 MOVE 64 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 9 TO WS-X1 MOVE 70 TO WS-Y1 MOVE 4 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 0 TO SP-F1(WS-BR)
     MOVE 1 TO SP-F2(WS-BR)
     MOVE 13 TO WS-BT MOVE 2 TO WS-BO MOVE 4 TO WS-BD
     MOVE 10 TO WS-X0 MOVE 64 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 14 TO WS-X1 MOVE 70 TO WS-Y1 MOVE 4 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 2 TO SP-F1(WS-BR)
     MOVE 0 TO SP-F2(WS-BR)
     MOVE 15 TO WS-BT MOVE 3 TO WS-BO MOVE 5 TO WS-BD
     MOVE 15 TO WS-X0 MOVE 64 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 21 TO WS-X1 MOVE 71 TO WS-Y1 MOVE 8 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 1 TO SP-F1(WS-BR)
     MOVE 1 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s01" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-8§3.5 saved keys: the fortress end filler holds Seed -123456, the turn pieces Chest 1 (pending) and 0, the throne Mob 1" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s01,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:nebef,BB:I[0,64,0,4,70,4],O:0,GD:2,Seed:-123456},"
         "{id:minecraft:nesclt,BB:I[5,64,0,9,70,4],O:1,GD:3,Chest:1},"
         "{id:minecraft:nescrt,BB:I[10,64,0,14,70,4],O:2,GD:4,Chest:0},"
         "{id:minecraft:nemt,BB:I[15,64,0,21,71,8],O:3,GD:5,Mob:1}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   the template pieces of the shipwreck (kind 2), the ocean ruin (3), the woodland mansion (5) and the end city (16) have registry names, so a start made of one of them is not INVALID
     MOVE "minecraft:shipwreck/with_mast" TO TP-KEY(1)
     CALL "SPB-RESET"
     MOVE 100 TO WS-BT MOVE 2 TO WS-BO MOVE 0 TO WS-BD
     MOVE 8 TO WS-X0 MOVE 60 TO WS-Y0 MOVE 8 TO WS-Z0 MOVE 16 TO WS-X1 MOVE 80 TO WS-Y1 MOVE 24 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 2 TO SP-T-KIND(WS-BR)
     MOVE 1 TO SP-T-ROW(WS-BR)
     MOVE 2 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s02" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-6§4.3 saved keys: a start with a shipwreck template piece is not INVALID (the piece id is shipwreck)" TO TL-CASE
     PERFORM CHECK-ID-START
     MOVE "minecraft:underwater_ruin/warm_1" TO TP-KEY(1)
     CALL "SPB-RESET"
     MOVE 100 TO WS-BT MOVE 2 TO WS-BO MOVE 0 TO WS-BD
     MOVE 8 TO WS-X0 MOVE 60 TO WS-Y0 MOVE 8 TO WS-Z0 MOVE 16 TO WS-X1 MOVE 80 TO WS-Y1 MOVE 24 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 3 TO SP-T-KIND(WS-BR)
     MOVE 1 TO SP-T-ROW(WS-BR)
     MOVE 3 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s03" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-6§2.4 saved keys: a start with an ocean ruin template piece is not INVALID (the piece id is orp)" TO TL-CASE
     PERFORM CHECK-ID-START
     MOVE "minecraft:woodland_mansion/entrance" TO TP-KEY(1)
     CALL "SPB-RESET"
     MOVE 100 TO WS-BT MOVE 2 TO WS-BO MOVE 0 TO WS-BD
     MOVE 8 TO WS-X0 MOVE 60 TO WS-Y0 MOVE 8 TO WS-Z0 MOVE 16 TO WS-X1 MOVE 80 TO WS-Y1 MOVE 24 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 5 TO SP-T-KIND(WS-BR)
     MOVE 1 TO SP-T-ROW(WS-BR)
     MOVE 4 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s04" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-7§3 saved keys: a start with a woodland mansion template piece is not INVALID (the piece id is wmp)" TO TL-CASE
     PERFORM CHECK-ID-START
     MOVE "minecraft:end_city/base_floor" TO TP-KEY(1)
     CALL "SPB-RESET"
     MOVE 100 TO WS-BT MOVE 2 TO WS-BO MOVE 0 TO WS-BD
     MOVE 8 TO WS-X0 MOVE 60 TO WS-Y0 MOVE 8 TO WS-Z0 MOVE 16 TO WS-X1 MOVE 80 TO WS-Y1 MOVE 24 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 16 TO SP-T-KIND(WS-BR)
     MOVE 1 TO SP-T-ROW(WS-BR)
     MOVE 5 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s05" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-8§9 saved keys: a start with an end city template piece is not INVALID (the piece id is ecp)" TO TL-CASE
     PERFORM CHECK-ID-START

*>   the mineshaft (36-5 2.5, 2.6, 2.11, 2.12): the corridor keeps hr, sc, hps (F1 to F3), Num (F4) and MST; the crossing tf (F1), D (the direction F2, the legacy 2D data value) and MST; a room its Entrances
*>   (the builder's SP-ENTRANCE boxes of the piece's run, a list of int arrays) and MST; the stairs MST only. The two rooms have runs of 2 and 1 boxes of the builder's table
     MOVE 1 TO WS-MST
     CALL "SPB-RESET"
     MOVE 0 TO WS-BT MOVE 2 TO WS-BO MOVE 3 TO WS-BD
     MOVE 0 TO WS-X0 MOVE 50 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 2 TO WS-X1 MOVE 52 TO WS-Y1 MOVE 14 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 1 TO SP-F1(WS-BR) MOVE 0 TO SP-F2(WS-BR) MOVE 1 TO SP-F3(WS-BR) MOVE 3 TO SP-F4(WS-BR)
     MOVE 1 TO WS-BT MOVE -1 TO WS-BO MOVE 4 TO WS-BD
     MOVE 0 TO WS-X0 MOVE 50 TO WS-Y0 MOVE 15 TO WS-Z0 MOVE 4 TO WS-X1 MOVE 56 TO WS-Y1 MOVE 19 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 1 TO SP-F1(WS-BR) MOVE 2 TO SP-F2(WS-BR)
     MOVE 2 TO WS-BT MOVE -1 TO WS-BO MOVE 2 TO WS-BD
     MOVE 10 TO WS-X0 MOVE 50 TO WS-Y0 MOVE 20 TO WS-Z0 MOVE 22 TO WS-X1 MOVE 55 TO WS-Y1 MOVE 32 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 1 TO SP-ENT-FIRST(WS-BR) MOVE 2 TO SP-ENT-N(WS-BR)
     MOVE 10 TO SE-X0(1) MOVE 51 TO SE-Y0(1) MOVE 20 TO SE-Z0(1) MOVE 12 TO SE-X1(1) MOVE 53 TO SE-Y1(1) MOVE 21 TO SE-Z1(1)
     MOVE 30 TO SE-X0(2) MOVE 52 TO SE-Y0(2) MOVE 20 TO SE-Z0(2) MOVE 32 TO SE-X1(2) MOVE 54 TO SE-Y1(2) MOVE 21 TO SE-Z1(2)
     MOVE 2 TO WS-BT MOVE -1 TO WS-BO MOVE 5 TO WS-BD
     MOVE 40 TO WS-X0 MOVE 50 TO WS-Y0 MOVE 20 TO WS-Z0 MOVE 50 TO WS-X1 MOVE 54 TO WS-Y1 MOVE 30 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 3 TO SP-ENT-FIRST(WS-BR) MOVE 1 TO SP-ENT-N(WS-BR)
     MOVE 45 TO SE-X0(3) MOVE 51 TO SE-Y0(3) MOVE 19 TO SE-Z0(3) MOVE 47 TO SE-X1(3) MOVE 53 TO SE-Y1(3) MOVE 21 TO SE-Z1(3)
     MOVE 3 TO SP-ENT-COUNT
     MOVE 3 TO WS-BT MOVE 3 TO WS-BO MOVE 6 TO WS-BD
     MOVE 60 TO WS-X0 MOVE 50 TO WS-Y0 MOVE 20 TO WS-Z0 MOVE 62 TO WS-X1 MOVE 54 TO WS-Y1 MOVE 24 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 6 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s06" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-5§2.5 saved keys: the mineshaft corridor, crossing, two rooms (Entrances of 2 and 1 boxes) and stairs are written with their keys" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s06,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:mscorridor,BB:I[0,50,0,2,52,14],O:2,GD:3,hr:1,sc:0,hps:1,Num:3,MST:1},"
         "{id:minecraft:mscrossing,BB:I[0,50,15,4,56,19],O:-1,GD:4,tf:1,D:2,MST:1},"
         "{id:minecraft:msroom,BB:I[10,50,20,22,55,32],O:-1,GD:2,Entrances:[I[10,51,20,12,53,21],I[30,52,20,32,54,21]],MST:1},"
         "{id:minecraft:msroom,BB:I[40,50,20,50,54,30],O:-1,GD:5,Entrances:[I[45,51,19,47,53,21]],MST:1},"
         "{id:minecraft:msstairs,BB:I[60,50,20,62,54,24],O:3,GD:6,MST:1}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE SST-ENT-COUNT TO TL-OBSERVED-N
     MOVE "acceptance US12 36-5§2.5 saved keys: the capture copies the three entrance boxes of the builder into the store" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   a room without entrance box writes an empty list (element type 0) and the type 0 MST
     MOVE 0 TO WS-MST
     CALL "SPB-RESET"
     MOVE 2 TO WS-BT MOVE -1 TO WS-BO MOVE 1 TO WS-BD
     MOVE 70 TO WS-X0 MOVE 50 TO WS-Y0 MOVE 20 TO WS-Z0 MOVE 80 TO WS-X1 MOVE 54 TO WS-Y1 MOVE 30 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 1 TO SP-ENT-FIRST(WS-BR) MOVE 0 TO SP-ENT-N(WS-BR)
     MOVE 7 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s07" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-5§2.5 saved keys: a room with no entrance box has an empty Entrances list and MST 0" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s07,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:msroom,BB:I[70,50,20,80,54,30],O:-1,GD:1,Entrances:[],MST:0}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   the starts written so far load into an empty store and write the same text again
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 7
         PERFORM SET-START-PATH
         PERFORM WRITE-AND-GET
         MOVE TL-OBSERVED TO WS-BEFORE(WS-S)
     END-PERFORM
     CALL "STRUCT-STORE-RESET"
     PERFORM READ-STRUCTURES
     MOVE 0 TO WS-SAME
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 7
         PERFORM SET-START-PATH
         PERFORM WRITE-AND-GET
         IF TL-OBSERVED = WS-BEFORE(WS-S)
             ADD 1 TO WS-SAME
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§2.5 saved keys: the seven starts load into an empty store and write the same keys again (the mineshaft room's Entrances too)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 6 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE SST-FIRST(WS-ROW) TO WS-P
     COMPUTE WS-I = WS-P + 3
     MOVE SPC-ENT-FIRST(WS-I) TO WS-Q
     MOVE "acceptance US12 36-5§2.5 saved keys: the second loaded room has a run of 1 entrance box at the store's third place, x0 45" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-ENT-N(WS-I) * 1000 + WS-Q * 100 + SSE-X0(WS-Q)
     MOVE 1345 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   reading: D is the 2D data value read as abs(v mod 4) (5 is west, -3 is east), MST outside 0 and 1 reads as 0, an Entrances entry of three ints is skipped, a list of strings gives no box,
*>   Entrances of a piece that is not a room is ignored, and the boxes of a piece that does not load (no BB) are not kept
     CALL "STRUCT-STORE-RESET"
     MOVE 7 TO WS-N
     PERFORM BEGIN-START
     MOVE "minecraft:mscrossing" TO WS-PID MOVE 20 TO WS-PIDLEN
     PERFORM PIECE-BEGIN
     MOVE "D" TO WN MOVE 1 TO WL MOVE 5 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     MOVE "MST" TO WN MOVE 3 TO WL MOVE 7 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM PIECE-BEGIN
     MOVE "D" TO WN MOVE 1 TO WL MOVE -3 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     MOVE "MST" TO WN MOVE 3 TO WL MOVE 1 TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "minecraft:msroom" TO WS-PID MOVE 16 TO WS-PIDLEN
     PERFORM PIECE-BEGIN
     MOVE "Entrances" TO WN MOVE 9 TO WL MOVE 11 TO WS-VALUE MOVE 3 TO WS-N
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-N
     MOVE 1 TO WS-BB-N(1) MOVE 2 TO WS-BB-N(2) MOVE 3 TO WS-BB-N(3) MOVE 4 TO WS-BB-N(4) MOVE 5 TO WS-BB-N(5) MOVE 6 TO WS-BB-N(6)
     MOVE -1 TO WL
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-BB
     MOVE 11 TO WS-BB-N(1) MOVE 12 TO WS-BB-N(2) MOVE 13 TO WS-BB-N(3) MOVE 14 TO WS-BB-N(4) MOVE 15 TO WS-BB-N(5) MOVE 16 TO WS-BB-N(6)
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM PIECE-BEGIN
     MOVE "Entrances" TO WN MOVE 9 TO WL MOVE 8 TO WS-VALUE MOVE 2 TO WS-N
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-N
     MOVE "ab" TO WS-STR MOVE 2 TO WS-STRLEN MOVE -1 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "minecraft:mscorridor" TO WS-PID MOVE 20 TO WS-PIDLEN
     PERFORM PIECE-BEGIN
     MOVE "Entrances" TO WN MOVE 9 TO WL MOVE 11 TO WS-VALUE MOVE 1 TO WS-N
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-N
     MOVE -1 TO WL
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB
     MOVE "hr" TO WN MOVE 2 TO WL MOVE 1 TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "minecraft:msroom" TO WS-PID MOVE 16 TO WS-PIDLEN
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-PID WS-PIDLEN
     MOVE "Entrances" TO WN MOVE 9 TO WL MOVE 11 TO WS-VALUE MOVE 1 TO WS-N
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-N
     MOVE 21 TO WS-BB-N(1) MOVE 22 TO WS-BB-N(2) MOVE 23 TO WS-BB-N(3) MOVE 24 TO WS-BB-N(4) MOVE 25 TO WS-BB-N(5) MOVE 26 TO WS-BB-N(6)
     MOVE -1 TO WL
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM PIECE-BEGIN
     MOVE "Entrances" TO WN MOVE 9 TO WL MOVE 11 TO WS-VALUE MOVE 1 TO WS-N
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-N
     MOVE 31 TO WS-BB-N(1) MOVE 32 TO WS-BB-N(2) MOVE 33 TO WS-BB-N(3) MOVE 34 TO WS-BB-N(4) MOVE 35 TO WS-BB-N(5) MOVE 36 TO WS-BB-N(6)
     MOVE -1 TO WL
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM CLOSE-START
     PERFORM READ-STRUCTURES
     MOVE 6 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE SST-FIRST(WS-ROW) TO WS-P
     MOVE "acceptance US12 36-5§2.11 saved keys: of seven mineshaft pieces the one without BB does not load (six left)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE SST-N(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-5§2.11 saved keys: a crossing with D 5 and MST 7 reads D 1 (abs(5 mod 4)) and MST 0 (out of range)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-K(WS-P, 2) * 10 + SPC-K(WS-P, 3)
     MOVE 10 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     COMPUTE WS-I = WS-P + 1
     MOVE "acceptance US12 36-5§2.11 saved keys: a crossing with D -3 and a byte MST 1 reads D 3 and MST 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-K(WS-I, 2) * 10 + SPC-K(WS-I, 3)
     MOVE 31 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     COMPUTE WS-I = WS-P + 2
     MOVE SPC-ENT-FIRST(WS-I) TO WS-Q
     COMPUTE WS-Q = WS-Q + 1
     MOVE "acceptance US12 36-5§2.5 saved keys: a room whose Entrances list has an entry of three ints keeps the two boxes of six, the second at x0 11" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-ENT-N(WS-I) * 100 + SSE-X0(WS-Q)
     MOVE 211 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     COMPUTE WS-I = WS-P + 3
     MOVE "acceptance US12 36-5§2.5 saved keys: a room whose Entrances list holds strings has no box" TO TL-CASE
     MOVE SPC-ENT-N(WS-I) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     COMPUTE WS-I = WS-P + 4
     MOVE "acceptance US12 36-5§2.6 saved keys: a corridor ignores Entrances and reads hr 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-ENT-N(WS-I) * 10 + SPC-K(WS-I, 1)
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     COMPUTE WS-I = WS-P + 5
     MOVE SPC-ENT-FIRST(WS-I) TO WS-Q
     MOVE "acceptance US12 36-5§2.5 saved keys: the boxes of the room that does not load are dropped: the last room holds the third box of the store, x0 31" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-ENT-COUNT * 1000 + WS-Q * 100 + SSE-X0(WS-Q)
     MOVE 3331 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   the store: a box added to a piece that is not the last one is lost, a full box table loses the next box, and a start put when the box table is within 256 of its end empties the store first
     CALL "STRUCT-STORE-RESET"
     MOVE 6 TO WS-S
     CALL "STRUCT-START-PUT" USING WS-S WS-CX WS-CZ WS-REFS WS-ROW
     MOVE 2 TO WS-BT
     CALL "STRUCT-START-PIECE-ADD" USING WS-ROW WS-BT WS-BO WS-BD WS-JIG WS-GROUND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-PROW
     CALL "STRUCT-START-PIECE-ADD" USING WS-ROW WS-BT WS-BO WS-BD WS-JIG WS-GROUND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P
     MOVE SST-LOST TO WS-LOST0
     CALL "STRUCT-START-ENTRANCE-ADD" USING WS-PROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     COMPUTE TL-OBSERVED-N = (SST-LOST - WS-LOST0) * 10000 + SST-ENT-COUNT * 10 + SPC-ENT-N(WS-PROW)
     MOVE "acceptance US12 36-5§2.5 saved keys: a box added to a piece that is not the last piece is lost and counted" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1025
         CALL "STRUCT-START-ENTRANCE-ADD" USING WS-P WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     END-PERFORM
     COMPUTE TL-OBSERVED-N = (SST-LOST - WS-LOST0) * 100000 + SST-ENT-COUNT
     MOVE "acceptance US12 36-5§2.5 saved keys: 1025 boxes added to the last piece leave 1024 and one more lost" TO TL-CASE
     MOVE 201024 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE 7 TO WS-S
     PERFORM CAPTURE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 10000 + SST-ENT-COUNT
     MOVE "acceptance US12 36-5§2.5 saved keys: a start put with 1024 boxes in the table empties the store first (one start, its box table emptied and refilled with its 0 boxes)" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     STOP RUN.

*> a builder piece of type WS-BT, orientation WS-BO, depth WS-BD, mineshaft type WS-MST and the box WS-X0.. (row in WS-BR)
 BUILDER-PIECE.
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-ADD" USING WS-BT WS-BO WS-BD WS-MST WS-BOX WS-BR.

*> the start of structure row WS-S held by chunk (0, 0)
 CAPTURE.
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-ROW.

*> the root compound, `structures`, `starts` and the start minecraft:s06 with a Children list of WS-N compounds (STRUCT-STARTS-READ reads from here)
 BEGIN-START.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:s06" TO WN MOVE 13 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Children" TO WN MOVE 8 TO WL
     MOVE 10 TO WS-VALUE
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-N.

 CLOSE-START.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

*> a piece compound of id WS-PID (length WS-PIDLEN) with the box (0, 0, 0, 1, 1, 1): the keys follow
 PIECE-BEGIN.
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-PID WS-PIDLEN
     MOVE "BB" TO WN MOVE 2 TO WL
     MOVE 0 TO WS-BB-N(1) MOVE 0 TO WS-BB-N(2) MOVE 0 TO WS-BB-N(3)
     MOVE 1 TO WS-BB-N(4) MOVE 1 TO WS-BB-N(5) MOVE 1 TO WS-BB-N(6)
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB.

 READ-STRUCTURES.
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE SPACES TO WN
     MOVE 32 TO WS-STRLEN
     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-STRLEN WL
     CALL "STRUCT-STARTS-READ" USING PB-BUFFER WS-CX WS-CZ WS-OUTCOME.

 SET-START-PATH.
     MOVE WS-S TO WS-DIGIT
     MOVE SPACES TO WS-PATH
     STRING "structures.starts.minecraft:s" WS-DIGIT DELIMITED BY SIZE INTO WS-PATH.

 CHECK-ID-START.
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT = "{id:INVALID}"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-NUM.

*> write the chunk's structures compound and read the tag at WS-PATH into TL-OBSERVED (and WS-TEXT)
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
 END PROGRAM TEST-STRUCT-PIECE-KEYS-REST.

 COPY CORETEST.
