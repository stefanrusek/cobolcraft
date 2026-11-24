*> The desert pyramid (docs/protocol/36-structures-4-scattered-and-small.md section 3; piece type 101): postProcess (the geometry tables SCP-DESERT-A to C of struct-scatter-gen.cob, the cellar with its
*> collapsed roof) and Structure.afterPlace (the suspicious sand). The frame, the table interpreter and the containers are in struct-scatter.cob.
*> Decisions: (1) the height is the lowest base height over the whole box (updateHeightPositionToLowestGroundHeight, see struct-scatter.cob) plus the offset -nextInt(3); the document draws that offset
*> from the piece random at every call and applies it at the first one, here it is drawn from the start random after the direction (the same value in every chunk pass) and the piece random still makes
*> its draw at every call, unused, so the chest seeds that follow are the document's. (2) The level random of the cellar (nextBoolean, 25 nextFloat of the roof) is the unseeded live random of the server
*> level in vanilla; here it is the start random's stream after those draws (the same in every pass). (3) The derived position random of 2.1 (createThreadLocalInstance(worldSeed).forkPositional().at(pos))
*> is the Java LCG seeded with Mth.getSeed(pos) xor the first nextLong of an LCG seeded with the world seed. (4) The brushable block entity is requested like a chest (kind 1: the loot table
*> minecraft:archaeology/desert_pyramid and the seed pos.asLong()).
*>
*> Entry points: SCP-DESERT-POST USING row (the draws, the ground adjuster, SCP-DESERT-BODY); SCP-DESERT-BODY USING row (the blocks after the adjuster); SCP-RESET (empties the lists, before a pass);
*> SCP-DESERT-AFTER (afterPlace, after the pieces of a pass); SCP-POS-RANDOM USING x y z, state out (u64): the derived position random.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDESERT.
 PROCEDURE DIVISION.
     MOVE 0 TO SCD-COUNT SCD-ROOF-SET
     GOBACK.
 END PROGRAM SCP-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-POS-RANDOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-T                   BINARY-DOUBLE UNSIGNED.
 01 WS-S                   BINARY-DOUBLE UNSIGNED.
 01 WS-G                   BINARY-DOUBLE.
 01 WS-GU                  BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     COMPUTE WS-USEED = FUNCTION MOD(SP-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-T WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-T WS-S
     CALL "XORO-GET-SEED" USING L-X L-Y L-Z WS-G
     COMPUTE WS-GU = FUNCTION MOD(WS-G + WS-M64, WS-M64)
     CALL "CBL_XOR" USING WS-S WS-GU BY VALUE 8
     CALL "JRAND-SET-SEED" USING L-STATE WS-GU
     GOBACK.
 END PROGRAM SCP-POS-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-CAND-ADD.
*> USING local x y z: records the world position of the piece-local cell as a potential suspicious sand block (the list holds 100).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDESERT.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     ADD 1 TO SCD-COUNT
     MOVE WS-WX TO SCD-CX(SCD-COUNT)
     MOVE WS-WY TO SCD-CY(SCD-COUNT)
     MOVE WS-WZ TO SCD-CZ(SCD-COUNT)
     GOBACK.
 END PROGRAM SCP-CAND-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-DESERT-BODY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTDESERT.
 01 WS-BITS                BINARY-DOUBLE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-B                   BINARY-LONG.
 01 WS-SPEC                PIC X(60).
 01 WS-SAND                BINARY-LONG.
 01 WS-SANDSTONE           BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG VALUE 0.3300000131130219.
 01 WS-RND                 BINARY-DOUBLE UNSIGNED.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 5.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG VALUE 0.
 01 WS-ARM-DXS.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE -3.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-ARM-DX-TABLE REDEFINES WS-ARM-DXS.
    05 WS-ARM-DX           BINARY-LONG OCCURS 4 TIMES.
 01 WS-ARM-DZS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE -3.
 01 WS-ARM-DZ-TABLE REDEFINES WS-ARM-DZS.
    05 WS-ARM-DZ           BINARY-LONG OCCURS 4 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-DESERT-A" USING L-ROW
*>   C2: the level random's boolean picks which of the two cells holds sand
     CALL "JRAND-NEXT" USING SP-RNG WS-ONE WS-BITS
     MOVE "sand" TO WS-SPEC
     CALL "SCP-STATE" USING L-ROW WS-SPEC WS-SAND
     MOVE "sandstone" TO WS-SPEC
     CALL "SCP-STATE" USING L-ROW WS-SPEC WS-SANDSTONE
     MOVE 15 TO WS-LX
     MOVE -1 TO WS-LY
     MOVE 17 TO WS-LZ
     IF WS-BITS NOT = 0
         MOVE WS-SAND TO WS-A
         MOVE WS-SANDSTONE TO WS-C
     ELSE
         MOVE WS-SANDSTONE TO WS-A
         MOVE WS-SAND TO WS-C
     END-IF
     CALL "SCP-SET" USING L-ROW WS-LX WS-LY WS-LZ WS-A
     MOVE 16 TO WS-LX
     CALL "SCP-SET" USING L-ROW WS-LX WS-LY WS-LZ WS-C
     CALL "SCP-DESERT-B" USING L-ROW
*>   C4: the 75 candidates of the box (X-2, Y+1, Z-2) to (X+2, Y+3, Z+2), loop y, x, z
     MOVE 0 TO SCD-COUNT
     PERFORM VARYING WS-Y FROM -3 BY 1 UNTIL WS-Y > -1
         PERFORM VARYING WS-X FROM 14 BY 1 UNTIL WS-X > 18
             PERFORM VARYING WS-Z FROM 11 BY 1 UNTIL WS-Z > 15
                 CALL "SCP-CAND-ADD" USING L-ROW WS-X WS-Y WS-Z
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   placeCollapsedRoof: at local y 0 sandstone below 0.33f, else sand; one draw per cell, x outer, z inner
     PERFORM VARYING WS-X FROM 14 BY 1 UNTIL WS-X > 18
         PERFORM VARYING WS-Z FROM 11 BY 1 UNTIL WS-Z > 15
             CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-DRAW
             IF WS-DRAW < WS-CHANCE
                 CALL "SCP-SET" USING L-ROW WS-X WS-Y0 WS-Z WS-SANDSTONE
             ELSE
                 CALL "SCP-SET" USING L-ROW WS-X WS-Y0 WS-Z WS-SAND
             END-IF
         END-PERFORM
     END-PERFORM
*>   randomCollapsedRoofPos: the derived random at the world position of local (X-2, 0, Z-2), rx then rz in [X-2, X+2] and [Z-2, Z+2]
     MOVE 14 TO WS-LX
     MOVE 11 TO WS-LZ
     CALL "SPB-WORLD" USING L-ROW WS-LX WS-Y0 WS-LZ WS-WX WS-WY WS-WZ
     CALL "SCP-POS-RANDOM" USING WS-WX WS-WY WS-WZ WS-RND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RND WS-BOUND WS-RX
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RND WS-BOUND WS-RZ
     ADD 14 TO WS-RX
     ADD 11 TO WS-RZ
     CALL "SPB-WORLD" USING L-ROW WS-RX WS-Y0 WS-RZ SCD-ROOF-X SCD-ROOF-Y SCD-ROOF-Z
     MOVE 1 TO SCD-ROOF-SET
     CALL "SCP-DESERT-C" USING L-ROW
*>   C5: the four arms' candidates: east, west, south, north, two cells above the floor each
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-LX = 16 + WS-ARM-DX(WS-K)
         COMPUTE WS-LZ = 13 + WS-ARM-DZ(WS-K)
         MOVE -3 TO WS-LY
         CALL "SCP-CAND-ADD" USING L-ROW WS-LX WS-LY WS-LZ
         MOVE -2 TO WS-LY
         CALL "SCP-CAND-ADD" USING L-ROW WS-LX WS-LY WS-LZ
     END-PERFORM
     GOBACK.
 END PROGRAM SCP-DESERT-BODY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-DESERT-POST.
*> USING row: postProcess of the pyramid (3.2): the piece random's adjust draw (unused, see the decisions above), the start random's adjust, the lowest ground height with that offset, the blocks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-BOUND               BINARY-LONG VALUE 3.
 01 WS-DISCARD             BINARY-LONG.
 01 WS-ADJ                 BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-LOWEST              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MSP-RNG-INT" USING WS-BOUND WS-DISCARD
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ADJ
     COMPUTE WS-OFFSET = 0 - WS-ADJ
     CALL "SCP-GROUND" USING L-ROW WS-LOWEST WS-OFFSET
     CALL "SCP-DESERT-BODY" USING L-ROW
     GOBACK.
 END PROGRAM SCP-DESERT-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-SUSPICIOUS.
*> USING world x y z: placeSuspiciousSand (3.5): inside the write box the cell becomes suspicious sand and its brushable block entity gets the loot table of the archaeology of the pyramid with the seed pos.asLong()
*> (y in bits 0 to 11, z in bits 12 to 37, x in bits 38 to 63, each masked to its width).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-IN                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:suspicious_sand".
 01 WS-PAIRS               PIC X(600) VALUE SPACES.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:archaeology/desert_pyramid".
 01 WS-NOTHING             PIC X(32) VALUE SPACES.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-XM                  BINARY-LONG.
 01 WS-ZM                  BINARY-LONG.
 01 WS-YM                  BINARY-LONG.
 01 WS-U                   PIC 9(20).
 01 WS-M63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SEED                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "SPB-BOX-INSIDE" USING SP-WBOX L-X L-Y L-Z WS-IN
     IF WS-IN = 1
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
         CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE WS-FLAGS WS-OK
         COMPUTE WS-XM = FUNCTION MOD(L-X, 67108864)
         COMPUTE WS-ZM = FUNCTION MOD(L-Z, 67108864)
         COMPUTE WS-YM = FUNCTION MOD(L-Y, 4096)
         COMPUTE WS-U = WS-XM * 274877906944 + WS-ZM * 4096 + WS-YM
         IF WS-U >= WS-M63
             COMPUTE WS-SEED = WS-U - WS-M64
         ELSE
             MOVE WS-U TO WS-SEED
         END-IF
         CALL "GBE-ADD" USING L-X L-Y L-Z WS-KIND WS-LOOT WS-SEED WS-NOTHING
     END-IF
     GOBACK.
 END PROGRAM SCP-SUSPICIOUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-DESERT-AFTER.
*> Structure.afterPlace of the pyramid (3.5), once per placement pass after the pieces: the roof's suspicious sand, then the candidates as a set sorted by (y, z, x) without duplicates, shuffled with
*> the derived random at the centre of the structure's box (Util.shuffle from the end, then n = 5 + nextInt(3), at most the set's size): the first n become suspicious sand, the others plain sand.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTDESERT.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-LESS                BINARY-LONG.
 01 WS-TMP.
    05 WS-TMP-X            BINARY-LONG.
    05 WS-TMP-Y            BINARY-LONG.
    05 WS-TMP-Z            BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-RND                 BINARY-DOUBLE UNSIGNED.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-IN                  BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:sand".
 01 WS-PAIRS               PIC X(600) VALUE SPACES.
 01 WS-SAND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     IF SCD-ROOF-SET = 0
         GOBACK
     END-IF
     CALL "SCP-SUSPICIOUS" USING SCD-ROOF-X SCD-ROOF-Y SCD-ROOF-Z
*>   the sorted set: insertion sort by y, then z, then x; then the duplicates are dropped
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SCD-COUNT
         MOVE SCD-CAND(WS-I) TO WS-TMP
         COMPUTE WS-J = WS-I - 1
         MOVE 1 TO WS-LESS
         PERFORM UNTIL WS-J < 1 OR WS-LESS = 0
             MOVE 0 TO WS-LESS
             IF WS-TMP-Y < SCD-CY(WS-J)
                 MOVE 1 TO WS-LESS
             END-IF
             IF WS-TMP-Y = SCD-CY(WS-J) AND WS-TMP-Z < SCD-CZ(WS-J)
                 MOVE 1 TO WS-LESS
             END-IF
             IF WS-TMP-Y = SCD-CY(WS-J) AND WS-TMP-Z = SCD-CZ(WS-J) AND WS-TMP-X < SCD-CX(WS-J)
                 MOVE 1 TO WS-LESS
             END-IF
             IF WS-LESS = 1
                 COMPUTE WS-K = WS-J + 1
                 MOVE SCD-CAND(WS-J) TO SCD-CAND(WS-K)
                 SUBTRACT 1 FROM WS-J
             END-IF
         END-PERFORM
         COMPUTE WS-K = WS-J + 1
         MOVE WS-TMP TO SCD-CAND(WS-K)
     END-PERFORM
     MOVE 0 TO WS-SIZE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCD-COUNT
         MOVE 1 TO WS-LESS
         IF WS-SIZE > 0
             IF SCD-CX(WS-I) = SCD-CX(WS-SIZE) AND SCD-CY(WS-I) = SCD-CY(WS-SIZE) AND SCD-CZ(WS-I) = SCD-CZ(WS-SIZE)
                 MOVE 0 TO WS-LESS
             END-IF
         END-IF
         IF WS-LESS = 1
             ADD 1 TO WS-SIZE
             MOVE SCD-CAND(WS-I) TO SCD-CAND(WS-SIZE)
         END-IF
     END-PERFORM
     MOVE WS-SIZE TO SCD-COUNT
*>   the derived random at the centre of the box that encapsulates the pieces
     CALL "SPB-UNION-ALL" USING WS-BOX
     CALL "SPB-BOX-CENTER" USING WS-BOX WS-CX WS-CY WS-CZ
     CALL "SCP-POS-RANDOM" USING WS-CX WS-CY WS-CZ WS-RND
     PERFORM VARYING WS-I FROM SCD-COUNT BY -1 UNTIL WS-I < 2
         MOVE WS-I TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RND WS-BOUND WS-DRAW
         COMPUTE WS-J = WS-DRAW + 1
         MOVE SCD-CAND(WS-I) TO WS-TMP
         MOVE SCD-CAND(WS-J) TO SCD-CAND(WS-I)
         MOVE WS-TMP TO SCD-CAND(WS-J)
     END-PERFORM
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RND WS-THREE WS-DRAW
     COMPUTE WS-N = 5 + WS-DRAW
     IF WS-N > SCD-COUNT
         MOVE SCD-COUNT TO WS-N
     END-IF
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-SAND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCD-COUNT
         IF WS-N > 0
             SUBTRACT 1 FROM WS-N
             CALL "SCP-SUSPICIOUS" USING SCD-CX(WS-I) SCD-CY(WS-I) SCD-CZ(WS-I)
         ELSE
             CALL "SPB-BOX-INSIDE" USING SP-WBOX SCD-CX(WS-I) SCD-CY(WS-I) SCD-CZ(WS-I) WS-IN
             IF WS-IN = 1
                 CALL "FL-SET-STATE" USING SCD-CX(WS-I) SCD-CY(WS-I) SCD-CZ(WS-I) WS-SAND WS-FLAGS WS-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCP-DESERT-AFTER.
