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
     STOP RUN.

*> a builder piece of type WS-BT, orientation WS-BO, depth WS-BD, mineshaft type WS-MST and the box WS-X0.. (row in WS-BR)
 BUILDER-PIECE.
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-ADD" USING WS-BT WS-BO WS-BD WS-MST WS-BOX WS-BR.

*> the start of structure row WS-S held by chunk (0, 0)
 CAPTURE.
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-ROW.

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
