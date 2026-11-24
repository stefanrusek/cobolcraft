*> Implementation test of the saved piece data of the scattered structures (docs/protocol/36-structures-4-scattered-and-small.md sections 2.4 and 10; core/src/struct-piece-keys.cob, struct-start.cob, struct-start-nbt.cob):
*> a start captured from the builder keeps the registry names of the desert pyramid (TeDP), jungle temple (TeJP), swamp hut (TeSH), igloo (Iglu), buried treasure (BTP), ruined portal (RUPO) and nether
*> fossil (NeFos) pieces (so a start made only of them is not INVALID) and the keys of the table of section 10 beyond id, BB, O and GD: Width, Height, Depth (from the box and the orientation), HPos and the
*> placed flags; Template, TPX, TPY, TPZ and Rot for the template pieces, the ruined portal's Rotation, Mirror, VerticalPlacement and Properties compound. A missing integer reads 0 and a missing boolean
*> false, a tag of the wrong type reads as absent, an unknown Rotation string reads as absent, and a written chunk compound loads back into the same keys. The builder is filled by hand with the values of the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-4-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-FIRST-TEXT          PIC X(8192).
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
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
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
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-BEFORES.
    05 WS-BEFORE           PIC X(1024) OCCURS 7 TIMES.
 01 WS-SAME                BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-ORD                 BINARY-LONG.
 01 WS-ENUM                PIC X(24).
 01 WS-KIND                PIC X.
 01 WS-MODE                BINARY-LONG.
 01 WS-SHORT               BINARY-LONG VALUE 77.
 01 WS-FLOAT               FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:s1" TO SDT-KEY(1)
     MOVE "minecraft:s2" TO SDT-KEY(2)
     MOVE "minecraft:s3" TO SDT-KEY(3)
     MOVE "minecraft:s4" TO SDT-KEY(4)
     MOVE "minecraft:s5" TO SDT-KEY(5)
     MOVE "minecraft:s6" TO SDT-KEY(6)
     MOVE "minecraft:s7" TO SDT-KEY(7)
     MOVE 7 TO SD-ST-COUNT
     MOVE 0 TO SDT-ADAPT(1) SDT-ADAPT(2) SDT-ADAPT(3) SDT-ADAPT(4) SDT-ADAPT(5) SDT-ADAPT(6) SDT-ADAPT(7)
     MOVE 1 TO TP-COUNT
     CALL "STRUCT-STORE-RESET"

*>   the enum spellings (36-4 section 10 and 36-5 section 3.9)
     MOVE "R" TO WS-KIND
     MOVE 3 TO WS-ORD
     MOVE 0 TO WS-MODE
     CALL "STRUCT-PIECE-ENUM" USING WS-KIND WS-MODE WS-ORD WS-ENUM
     MOVE "acceptance US12 36-4§10 Saved piece data: Rotation ordinal 3 is COUNTERCLOCKWISE_90" TO TL-CASE
     MOVE "COUNTERCLOCKWISE_90" TO TL-EXPECTED
     MOVE WS-ENUM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "V" TO WS-KIND
     MOVE 5 TO WS-ORD
     CALL "STRUCT-PIECE-ENUM" USING WS-KIND WS-MODE WS-ORD WS-ENUM
     MOVE "acceptance US12 36-4§10 Saved piece data: VerticalPlacement ordinal 5 is in_nether" TO TL-CASE
     MOVE "in_nether" TO TL-EXPECTED
     MOVE WS-ENUM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "M" TO WS-KIND
     MOVE 1 TO WS-MODE
     MOVE "FRONT_BACK" TO WS-ENUM
     CALL "STRUCT-PIECE-ENUM" USING WS-KIND WS-MODE WS-ORD WS-ENUM
     MOVE "acceptance US12 36-4§10 Saved piece data: Mirror FRONT_BACK is ordinal 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ORD TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "clockwise_90" TO WS-ENUM
     MOVE "R" TO WS-KIND
     CALL "STRUCT-PIECE-ENUM" USING WS-KIND WS-MODE WS-ORD WS-ENUM
     MOVE "acceptance US12 36-4§10 Saved piece data: the lower-case clockwise_90 is not a Rotation constant (-1)" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-ORD TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   the builder: a desert pyramid facing north, the box (20, 64, -40) to (40, 78, -20): 21 wide, 15 high, 21 deep; HPos 63; chests 0 and 2 placed
     CALL "SPB-RESET"
     MOVE 101 TO WS-BT
     MOVE 2 TO WS-BO
     MOVE 20 TO WS-X0 MOVE 64 TO WS-Y0 MOVE -40 TO WS-Z0 MOVE 40 TO WS-X1 MOVE 78 TO WS-Y1 MOVE -20 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 63 TO SP-T-AUX(WS-BR)
     MOVE 1 TO SP-F1(WS-BR) SP-F3(WS-BR)
     MOVE 1 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s1" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-4§10 Saved piece data: the desert pyramid is TeDP with Width 21, Height 15, Depth 21, HPos 63 and hasPlacedChest0 to 3 = 1, 0, 1, 0" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s1,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:tedp,BB:I[20,64,-40,40,78,-20],O:2,GD:0,Width:21,Height:15,Depth:21,HPos:63,"
         "hasPlacedChest0:1,hasPlacedChest1:0,hasPlacedChest2:1,hasPlacedChest3:0}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   a jungle temple facing east: the box is 15 along x and 12 along z, so Width 12 and Depth 15; the builder's flags are trap 1, trap 2, main chest, hidden chest
     CALL "SPB-RESET"
     MOVE 102 TO WS-BT
     MOVE 3 TO WS-BO
     MOVE 0 TO WS-X0 MOVE 64 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 14 TO WS-X1 MOVE 73 TO WS-Y1 MOVE 11 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 70 TO SP-T-AUX(WS-BR)
     MOVE 1 TO SP-F1(WS-BR) SP-F4(WS-BR)
     MOVE 2 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s2" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-4§10 Saved piece data: the jungle temple is TeJP, Width 12, Height 10, Depth 15 (east swaps the horizontal extents), main chest 0, hidden chest 1, trap 1 = 1, trap 2 = 0" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s2,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:tejp,BB:I[0,64,0,14,73,11],O:3,GD:0,Width:12,Height:10,Depth:15,HPos:70,"
         "placedMainChest:0,placedHiddenChest:1,placedTrap1:1,placedTrap2:0}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   a swamp hut facing south: 7 along x, 9 along z; the witch and the cat spawned
     CALL "SPB-RESET"
     MOVE 103 TO WS-BT
     MOVE 0 TO WS-BO
     MOVE 0 TO WS-X0 MOVE 64 TO WS-Y0 MOVE 0 TO WS-Z0 MOVE 6 TO WS-X1 MOVE 70 TO WS-Y1 MOVE 8 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 62 TO SP-T-AUX(WS-BR)
     MOVE 1 TO SP-F1(WS-BR) SP-F2(WS-BR)
     MOVE 3 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s3" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-4§10 Saved piece data: the swamp hut is TeSH, Width 7, Height 7, Depth 9, HPos 62, Witch 1 and Cat 1" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s3,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:tesh,BB:I[0,64,0,6,70,8],O:0,GD:0,Width:7,Height:7,Depth:9,HPos:62,Witch:1,Cat:1}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   the igloo (template kind 1): Template, TPX, TPY, TPZ and Rot (CLOCKWISE_180 for code 2)
     MOVE "minecraft:igloo/top" TO TP-KEY(1)
     CALL "SPB-RESET"
     MOVE 100 TO WS-BT
     MOVE 2 TO WS-BO
     MOVE 4 TO WS-X0 MOVE 90 TO WS-Y0 MOVE 8 TO WS-Z0 MOVE 10 TO WS-X1 MOVE 98 TO WS-Y1 MOVE 14 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 1 TO SP-T-KIND(WS-BR)
     MOVE 1 TO SP-T-ROW(WS-BR)
     MOVE 5 TO SP-T-X(WS-BR)
     MOVE 90 TO SP-T-Y(WS-BR)
     MOVE 9 TO SP-T-Z(WS-BR)
     MOVE 2 TO SP-T-ROT(WS-BR)
     MOVE 4 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s4" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-4§10 Saved piece data: the igloo piece is Iglu with Template minecraft:igloo/top, TPX 5, TPY 90, TPZ 9 and Rot CLOCKWISE_180" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s4,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:iglu,BB:I[4,90,8,10,98,14],O:2,GD:0,Template:minecraft:igloo/top,TPX:5,TPY:90,TPZ:9,Rot:CLOCKWISE_180}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   the nether fossil (kind 0) with Rot COUNTERCLOCKWISE_90 and the buried treasure (104, no keys): a start made of one piece each is not INVALID
     MOVE "minecraft:nether_fossils/fossil_14" TO TP-KEY(1)
     CALL "SPB-RESET"
     MOVE 100 TO WS-BT
     MOVE 1 TO WS-BO
     MOVE 16 TO WS-X0 MOVE 40 TO WS-Y0 MOVE 16 TO WS-Z0 MOVE 22 TO WS-X1 MOVE 46 TO WS-Y1 MOVE 21 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 0 TO SP-T-KIND(WS-BR)
     MOVE 1 TO SP-T-ROW(WS-BR)
     MOVE 16 TO SP-T-X(WS-BR)
     MOVE 41 TO SP-T-Y(WS-BR)
     MOVE 17 TO SP-T-Z(WS-BR)
     MOVE 3 TO SP-T-ROT(WS-BR)
     MOVE 5 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s5" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-4§10 Saved piece data: the nether fossil piece is NeFos with the template minecraft:nether_fossils/fossil_14 and Rot COUNTERCLOCKWISE_90" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s5,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:nefos,BB:I[16,40,16,22,46,21],O:1,GD:0,Template:minecraft:nether_fossils/fossil_14,TPX:16,TPY:41,TPZ:17,Rot:COUNTERCLOCKWISE_90}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     CALL "SPB-RESET"
     MOVE 104 TO WS-BT
     MOVE -1 TO WS-BO
     MOVE 9 TO WS-X0 MOVE 90 TO WS-Y0 MOVE 9 TO WS-Z0 MOVE 9 TO WS-X1 MOVE 90 TO WS-Y1 MOVE 9 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 6 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s6" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-4§10 Saved piece data: the buried treasure piece is BTP with no keys beyond id, BB, O and GD (the start is not INVALID)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s6,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:btp,BB:I[9,90,9,9,90,9],O:-1,GD:0}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   the ruined portal (kind 4): placement on_ocean_floor (2), Properties air_pocket, vines and cold, mossiness 0.8, Rotation CLOCKWISE_180, Mirror LEFT_RIGHT
     MOVE "minecraft:ruined_portal/portal_3" TO TP-KEY(1)
     CALL "SPB-RESET"
     MOVE 100 TO WS-BT
     MOVE 2 TO WS-BO
     MOVE 30 TO WS-X0 MOVE 60 TO WS-Y0 MOVE 30 TO WS-Z0 MOVE 36 TO WS-X1 MOVE 66 TO WS-Y1 MOVE 34 TO WS-Z1
     PERFORM BUILDER-PIECE
     MOVE 4 TO SP-T-KIND(WS-BR)
     MOVE 1 TO SP-T-ROW(WS-BR)
     MOVE 30 TO SP-T-X(WS-BR)
     MOVE 60 TO SP-T-Y(WS-BR)
     MOVE 30 TO SP-T-Z(WS-BR)
     MOVE 2 TO SP-T-ROT(WS-BR)
     MOVE 1 TO SP-T-MIR(WS-BR)
*>   air 1 + vines 4 + cold 8, 32 times the placement 2, 256 times the mossiness 8 (tenths)
     COMPUTE SP-T-AUX(WS-BR) = 1 + 4 + 8 + 2 * 32 + 8 * 256
     MOVE 7 TO WS-S
     PERFORM CAPTURE
     MOVE "structures.starts.minecraft:s7" TO WS-PATH
     PERFORM WRITE-AND-GET
     MOVE "acceptance US12 36-4§10 Saved piece data: the ruined portal is RUPO with Template, TPX/TPY/TPZ, Rotation, Mirror, VerticalPlacement on_ocean_floor and the Properties compound" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:s7,ChunkX:0,ChunkZ:0,references:0,Children:["
         "{id:minecraft:rupo,BB:I[30,60,30,36,66,34],O:2,GD:0,Template:minecraft:ruined_portal/portal_3,TPX:30,TPY:60,TPZ:30,"
         "Rotation:CLOCKWISE_180,Mirror:LEFT_RIGHT,VerticalPlacement:on_ocean_floor,"
         "Properties:{cold:1,mossiness:0.800,air_pocket:1,overgrown:0,vines:1,replace_with_blackstone:0}}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   all seven starts: written, loaded into an empty store and written again, every start's text is the same
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
     MOVE "acceptance US12 36-4§10 Saved piece data: the seven starts of the scattered family load into an empty store and write the same keys again" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 7 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE SST-FIRST(WS-ROW) TO WS-P
     MOVE "acceptance US12 36-4§10 Saved piece data: the reloaded ruined portal piece holds TPX 30, Rotation 2, Mirror 1, placement 2, property bits 13 and mossiness 8" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-K(WS-P, 1) * 100000000 + SPC-K(WS-P, 4) * 10000000 + SPC-K(WS-P, 5) * 1000000
         + SPC-K(WS-P, 6) * 100000 + SPC-K(WS-P, 7) * 1000 + SPC-K(WS-P, 8)
     MOVE 3021213008 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-4§10 Saved piece data: the reloaded ruined portal piece holds the Template string" TO TL-CASE
     MOVE "minecraft:ruined_portal/portal_3" TO TL-EXPECTED
     MOVE SPC-TPL(WS-P) TO TL-OBSERVED
     PERFORM CHECK-TEXT

*>   missing keys: a TeDP piece with only id and BB reads Width, Height, Depth, HPos and the flags as 0; a Width of the wrong type (string) reads as absent
     CALL "STRUCT-STORE-RESET"
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:s1" TO WN MOVE 12 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Children" TO WN MOVE 8 TO WL
     MOVE 10 TO WS-VALUE
     MOVE 1 TO WS-KEYLEN
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-KEYLEN
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL
     MOVE "minecraft:TeDP" TO WS-STR MOVE 14 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     PERFORM PUT-BB
     MOVE "Width" TO WN MOVE 5 TO WL
     MOVE "twenty-one" TO WS-STR MOVE 10 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     MOVE "Depth" TO WN MOVE 5 TO WL
     MOVE 21 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM READ-STRUCTURES
     MOVE 1 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE SST-FIRST(WS-ROW) TO WS-P
     MOVE "acceptance US12 36-4§10 Saved piece data: a missing integer or boolean reads 0 and a Width of the wrong tag type reads as absent; Depth 21 is kept" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-N(WS-ROW) * 10000000 + SPC-K(WS-P, 1) * 1000000 + SPC-K(WS-P, 3) * 10000 + SPC-K(WS-P, 4) * 100 + SPC-K(WS-P, 5) + SPC-K(WS-P, 8)
     MOVE 10210000 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   a number of another width reads as a number: Height as a short, Width as a float (its integer part), and the portal's mossiness as a byte (tenths = 10 times)
     CALL "STRUCT-STORE-RESET"
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:s1" TO WN MOVE 12 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Children" TO WN MOVE 8 TO WL
     MOVE 10 TO WS-VALUE
     MOVE 2 TO WS-KEYLEN
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-VALUE WS-KEYLEN
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL
     MOVE "minecraft:tedp" TO WS-STR MOVE 14 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     PERFORM PUT-BB
     MOVE "Height" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-SHORT
     MOVE "Width" TO WN MOVE 5 TO WL
     MOVE 21.5 TO WS-FLOAT
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL
     MOVE "minecraft:rupo" TO WS-STR MOVE 14 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     PERFORM PUT-BB
     MOVE "Properties" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "mossiness" TO WN MOVE 9 TO WL
     MOVE 1 TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "vines" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "cold" TO WN MOVE 4 TO WL
     MOVE "yes" TO WS-STR MOVE 3 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM READ-STRUCTURES
     MOVE 1 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE SST-FIRST(WS-ROW) TO WS-P
     MOVE "acceptance US12 36-4§10 Saved piece data: a short Height 77 and a float Width 21.5 read as 77 and 21" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-K(WS-P, 1) * 1000 + SPC-K(WS-P, 2)
     MOVE 21077 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     ADD 1 TO WS-P
     MOVE "acceptance US12 36-4§10 Saved piece data: the portal's Properties read vines (bit 4), a byte mossiness 1 as 10 tenths and ignore a string cold" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-K(WS-P, 7) * 100 + SPC-K(WS-P, 8)
     MOVE 410 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     STOP RUN.

*> a builder piece of type WS-BT, orientation WS-BO and the box WS-X0.. (row in WS-BR)
 BUILDER-PIECE.
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-ADD" USING WS-BT WS-BO WS-ZERO WS-ZERO2 WS-BOX WS-BR.

*> the start of structure row WS-S held by chunk (0, 0)
 CAPTURE.
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-ROW.

 PUT-BB.
     MOVE "BB" TO WN MOVE 2 TO WL
     MOVE 0 TO WS-BB-N(1) WS-BB-N(2) WS-BB-N(3)
     MOVE 1 TO WS-BB-N(4) WS-BB-N(5) WS-BB-N(6)
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

*> write the chunk's structures compound and read the tag at WS-PATH into TL-OBSERVED
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
 END PROGRAM TEST-STRUCT-36-4-10.

 COPY CORETEST.
