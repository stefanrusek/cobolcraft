*> The tree decorators (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 3): FD-DECO-NODE compiles one decorator object into a slot TR-DEC of a feature row, FR-DECORATE
*> runs the decorators of a slot range over the logs of the work area of TREEWORK.cpy (TW-LOG) in the order of the decorator context (3.1: the list sorted by y, stable; positions of the same y
*> keep the order they were placed in, where the game keeps the order of its hash set, Open question 1 there), with the draws in the doc's order.
*> Supported here: attached_to_logs (3.3, used by the fallen trees), trunk_vine, leave_vine and cocoa. The beehive (the nest has bees: no block entity can be written by the generator),
*> alter_ground (the podzol_beneath_tree provider is a named rule_based provider the compiler does not load), attached_to_leaves (the propagule provider is not specified), place_on_ground,
*> shelf_mushroom, pale_moss and creaking_heart are accepted and ignored: their draws are not made.
*>
*> Entry points: FD-DECO-NODE USING doc, decorator node, row, slot; FR-DECORATE USING state, row, first slot, count.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-DECO-NODE.
*> USING doc, decorator node, row, slot: the type (kind in TD-KIND, 0 for a registered type that is accepted and ignored) and the fields of the supported kinds; an unregistered type, or a
*> provider or direction list the compiler cannot read, sets FD-BAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-PROB              PIC X(40) VALUE "probability".
 01 WS-K-PROVIDER          PIC X(40) VALUE "block_provider".
 01 WS-K-DIRS              PIC X(40) VALUE "directions".
 01 WS-K-PROVIDER-ALT      PIC X(40) VALUE "provider".
 01 WS-K-TRIES             PIC X(40) VALUE "tries".
 01 WS-K-RADIUS            PIC X(40) VALUE "radius".
 01 WS-K-HEIGHT            PIC X(40) VALUE "height".
 01 WS-K-BSP               PIC X(40) VALUE "block_state_provider".
 01 WS-K-EXC-XZ            PIC X(40) VALUE "exclusion_radius_xz".
 01 WS-K-EXC-Y             PIC X(40) VALUE "exclusion_radius_y".
 01 WS-K-REQ               PIC X(40) VALUE "required_empty_blocks".
 01 WS-K-LEAVES-P          PIC X(40) VALUE "leaves_probability".
 01 WS-K-TRUNK-P           PIC X(40) VALUE "trunk_probability".
 01 WS-K-GROUND-P          PIC X(40) VALUE "ground_probability".
 01 WS-PATCH-KEY           PIC X(80) VALUE "minecraft:pale_moss_patch".
 01 WS-DECOS.
    05 FILLER              PIC X(40) VALUE "minecraft:attached_to_logs".
    05 FILLER              PIC X(40) VALUE "minecraft:beehive".
    05 FILLER              PIC X(40) VALUE "minecraft:trunk_vine".
    05 FILLER              PIC X(40) VALUE "minecraft:leave_vine".
    05 FILLER              PIC X(40) VALUE "minecraft:cocoa".
    05 FILLER              PIC X(40) VALUE "minecraft:alter_ground".
    05 FILLER              PIC X(40) VALUE "minecraft:place_on_ground".
    05 FILLER              PIC X(40) VALUE "minecraft:shelf_mushroom".
    05 FILLER              PIC X(40) VALUE "minecraft:attached_to_leaves".
    05 FILLER              PIC X(40) VALUE "minecraft:pale_moss".
    05 FILLER              PIC X(40) VALUE "minecraft:creaking_heart".
 01 WS-DECO-TABLE REDEFINES WS-DECOS.
    05 WS-DECO             PIC X(40) OCCURS 11 TIMES.
 01 WS-DIRNAMES.
    05 FILLER              PIC X(8) VALUE "down".
    05 FILLER              PIC X(8) VALUE "up".
    05 FILLER              PIC X(8) VALUE "north".
    05 FILLER              PIC X(8) VALUE "south".
    05 FILLER              PIC X(8) VALUE "west".
    05 FILLER              PIC X(8) VALUE "east".
 01 WS-DIRNAME-TABLE REDEFINES WS-DIRNAMES.
    05 WS-DIRNAME          PIC X(8) OCCURS 6 TIMES.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 120.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW L-SLOT.
     GO TO MAIN-LINE.
 READ-DIRS.
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-DIRS WS-E
     IF WS-E = 0
         MOVE 1 TO FD-BAD
     ELSE
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E)
             CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
             MOVE SPACES TO WS-TEXT
             CALL "JSON-STRING" USING JSON-DOC WS-N WS-TEXT WS-CAP WS-LEN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
                 IF WS-DIRNAME(WS-J) = WS-TEXT
                     ADD 1 TO TD-ND(L-ROW, L-SLOT)
                     COMPUTE TD-DIR(L-ROW, L-SLOT, TD-ND(L-ROW, L-SLOT)) = WS-J - 1
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
     IF TD-ND(L-ROW, L-SLOT) = 0
         MOVE 1 TO FD-BAD
     END-IF
     .
 MAIN-LINE.
     INITIALIZE TR-DEC(L-ROW, L-SLOT)
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     MOVE 0 TO WS-KNOWN
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 11
         IF WS-DECO(WS-J) = WS-TEXT
             MOVE 1 TO WS-KNOWN
         END-IF
     END-PERFORM
     IF WS-KNOWN = 0
         MOVE 1 TO FD-BAD
     END-IF
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:attached_to_logs"
             MOVE 1 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-PROVIDER WS-E
             CALL "FD-PROV-NODE" USING JSON-DOC WS-E TD-PV(L-ROW, L-SLOT)
             PERFORM READ-DIRS
         WHEN "minecraft:trunk_vine"
             MOVE 2 TO TD-KIND(L-ROW, L-SLOT)
         WHEN "minecraft:leave_vine"
             MOVE 3 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
         WHEN "minecraft:cocoa"
             MOVE 4 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
         WHEN "minecraft:beehive"
             MOVE 5 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
         WHEN "minecraft:alter_ground"
             MOVE 6 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-PROVIDER-ALT WS-E
             CALL "FD-PROV-NODE" USING JSON-DOC WS-E TD-PV(L-ROW, L-SLOT)
         WHEN "minecraft:place_on_ground"
             MOVE 7 TO TD-KIND(L-ROW, L-SLOT)
             MOVE 128 TO TD-I(L-ROW, L-SLOT, 1)
             MOVE 2 TO TD-I(L-ROW, L-SLOT, 2)
             MOVE 1 TO TD-I(L-ROW, L-SLOT, 3)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-TRIES WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E TD-I(L-ROW, L-SLOT, 1) WS-N
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RADIUS WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E TD-I(L-ROW, L-SLOT, 2) WS-N
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-HEIGHT WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E TD-I(L-ROW, L-SLOT, 3) WS-N
             END-IF
             IF TD-I(L-ROW, L-SLOT, 1) < 1 OR TD-I(L-ROW, L-SLOT, 2) < 0 OR TD-I(L-ROW, L-SLOT, 3) < 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BSP WS-E
             CALL "FD-PROV-NODE" USING JSON-DOC WS-E TD-PV(L-ROW, L-SLOT)
         WHEN "minecraft:shelf_mushroom"
             MOVE 8 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
         WHEN "minecraft:attached_to_leaves"
             MOVE 9 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
             MOVE 0 TO TD-I(L-ROW, L-SLOT, 1) TD-I(L-ROW, L-SLOT, 2)
             MOVE 1 TO TD-I(L-ROW, L-SLOT, 3)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-EXC-XZ WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E TD-I(L-ROW, L-SLOT, 1) WS-N
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-EXC-Y WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E TD-I(L-ROW, L-SLOT, 2) WS-N
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REQ WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E TD-I(L-ROW, L-SLOT, 3) WS-N
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-PROVIDER WS-E
             CALL "FD-PROV-NODE" USING JSON-DOC WS-E TD-PV(L-ROW, L-SLOT)
             PERFORM READ-DIRS
         WHEN "minecraft:pale_moss"
             MOVE 10 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-LEAVES-P WS-ZERO TD-PROB(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-TRUNK-P WS-ZERO TD-F2(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-GROUND-P WS-ZERO TD-F3(L-ROW, L-SLOT)
             CALL "FD-GET-FT" USING WS-PATCH-KEY TD-FT(L-ROW, L-SLOT)
         WHEN "minecraft:creaking_heart"
             MOVE 11 TO TD-KIND(L-ROW, L-SLOT)
             CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
     END-EVALUATE
     CONTINUE.
 END PROGRAM FD-DECO-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-SORT.
*> USING (nothing): TW-LS = the indices of the logs TW-LOG(1 .. TW-NLOG) sorted by y, positions of equal y in the order placed (3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-N
     MOVE 999999 TO WS-MIN
     MOVE -999999 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         IF TW-LOG-Y(WS-I) < WS-MIN
             MOVE TW-LOG-Y(WS-I) TO WS-MIN
         END-IF
         IF TW-LOG-Y(WS-I) > WS-MAX
             MOVE TW-LOG-Y(WS-I) TO WS-MAX
         END-IF
     END-PERFORM
     PERFORM VARYING WS-Y FROM WS-MIN BY 1 UNTIL WS-Y > WS-MAX
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
             IF TW-LOG-Y(WS-I) = WS-Y
                 ADD 1 TO WS-N
                 MOVE WS-I TO TW-LS(WS-N)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-SORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-SHUFFLE.
*> USING state, count: TW-SH = a shuffled copy of TW-LS(1 .. count): Collections.shuffle, for i = count down to 2 swap element i - 1 with element nextInt(i) (3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-N.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         MOVE TW-LS(WS-I) TO TW-SH(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM L-N BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-I WS-J
         MOVE TW-SH(WS-J + 1) TO WS-T
         MOVE TW-SH(WS-I) TO TW-SH(WS-J + 1)
         MOVE WS-T TO TW-SH(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-SHUFFLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-LOGS.
*> USING state, row, slot: attached_to_logs (3.3): a shuffled copy of the logs; for each log draw a direction of the list (nextInt(size)) and then nextFloat(); when the float is at most the
*> probability and the cell beside the log in that direction is air, the block provider's state goes there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-P
     CALL "FR-F32" USING WS-P
     CALL "FR-DEC-SHUFFLE" USING L-STATE TW-NLOG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         MOVE TW-SH(WS-I) TO WS-K
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE TD-ND(L-ROW, L-SLOT) WS-DIR
         MOVE TD-DIR(L-ROW, L-SLOT, WS-DIR + 1) TO WS-DIR
         CALL "F353-STEP" USING WS-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-PX = TW-LOG-X(WS-K) + WS-DX
         COMPUTE WS-PY = TW-LOG-Y(WS-K) + WS-DY
         COMPUTE WS-PZ = TW-LOG-Z(WS-K) + WS-DZ
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-F <= WS-P AND WS-CLASS = 1
             CALL "FR-PROV-STATE" USING L-STATE TD-PV(L-ROW, L-SLOT) WS-PX WS-PY WS-PZ WS-NEW WS-OK
             IF WS-OK = 1
                 CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-NEW WS-FLAGS WS-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-LOGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-SORTL.
*> USING (nothing): TW-LFS = the indices of the leaves TW-LEAF(1 .. TW-NLEAF) sorted by y, positions of equal y in the order placed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-N
     MOVE 999999 TO WS-MIN
     MOVE -999999 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLEAF
         IF TW-LEAF-Y(WS-I) < WS-MIN
             MOVE TW-LEAF-Y(WS-I) TO WS-MIN
         END-IF
         IF TW-LEAF-Y(WS-I) > WS-MAX
             MOVE TW-LEAF-Y(WS-I) TO WS-MAX
         END-IF
     END-PERFORM
     PERFORM VARYING WS-Y FROM WS-MIN BY 1 UNTIL WS-Y > WS-MAX
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLEAF
             IF TW-LEAF-Y(WS-I) = WS-Y
                 ADD 1 TO WS-N
                 MOVE WS-I TO TW-LFS(WS-N)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-SORTL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-VINE-STATE.
*> USING face (the direction ordinal of the face that is set: NORTH 2, SOUTH 3, WEST 4, EAST 5), state out (0 when the block table has no vine of 32 states): the vine with that one face set.
*> The 32 states are the five booleans east, north, south, up, west sorted by name, true first (24 part 4 6.7 and the numbering of 04 5.2): the state of all false is the last, and a set
*> face subtracts its stride (west 1, up 2, south 4, north 8, east 16).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:vine".
 01 WS-B                   BINARY-LONG.
 01 WS-STRIDE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-STATE.
     MOVE 0 TO L-STATE
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-B
     IF WS-B > 0
         IF CB-STATES(WS-B) = 32
             EVALUATE L-FACE
                 WHEN 2
                     MOVE 8 TO WS-STRIDE
                 WHEN 3
                     MOVE 4 TO WS-STRIDE
                 WHEN 4
                     MOVE 1 TO WS-STRIDE
                 WHEN OTHER
                     MOVE 16 TO WS-STRIDE
             END-EVALUATE
             COMPUTE L-STATE = CB-FIRST-STATE(WS-B) + 31 - WS-STRIDE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-VINE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-VINES.
*> USING state, row, slot: trunk_vine (kind 2) and leave_vine (kind 3) (3.3): over the logs, or the leaves, in the order of the context; four sides in the order west, east, north, south. trunk_vine
*> draws nextInt(3) for each side and a value above 0 puts a vine on an air side with the face that points back at the log; leave_vine draws nextFloat() and a value below the probability puts a
*> hanging vine there (the vine, then up to 4 more below it while the cell is air).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-VINE                BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-P
     CALL "FR-F32" USING WS-P
     MOVE TW-NLOG TO WS-N
     IF TD-KIND(L-ROW, L-SLOT) = 3
         CALL "FR-DEC-SORTL"
         MOVE TW-NLEAF TO WS-N
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF TD-KIND(L-ROW, L-SLOT) = 3
             MOVE TW-LFS(WS-I) TO WS-K
             MOVE TW-LEAF-X(WS-K) TO WS-PX
             MOVE TW-LEAF-Y(WS-K) TO WS-PY
             MOVE TW-LEAF-Z(WS-K) TO WS-PZ
         ELSE
             MOVE TW-LS(WS-I) TO WS-K
             MOVE TW-LOG-X(WS-K) TO WS-PX
             MOVE TW-LOG-Y(WS-K) TO WS-PY
             MOVE TW-LOG-Z(WS-K) TO WS-PZ
         END-IF
         PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 3
             MOVE 0 TO WS-DX WS-DZ
             EVALUATE WS-S
                 WHEN 0
                     MOVE -1 TO WS-DX
                     MOVE 5 TO WS-FACE
                 WHEN 1
                     MOVE 1 TO WS-DX
                     MOVE 4 TO WS-FACE
                 WHEN 2
                     MOVE -1 TO WS-DZ
                     MOVE 3 TO WS-FACE
                 WHEN OTHER
                     MOVE 1 TO WS-DZ
                     MOVE 2 TO WS-FACE
             END-EVALUATE
             MOVE 0 TO WS-FIRE
             IF TD-KIND(L-ROW, L-SLOT) = 3
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                 IF WS-F < WS-P
                     MOVE 1 TO WS-FIRE
                 END-IF
             ELSE
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-DRAW
                 IF WS-DRAW > 0
                     MOVE 1 TO WS-FIRE
                 END-IF
             END-IF
             COMPUTE WS-NX = WS-PX + WS-DX
             COMPUTE WS-NZ = WS-PZ + WS-DZ
             CALL "FL-GET-STATE" USING WS-NX WS-PY WS-NZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-FIRE = 1 AND WS-CLASS = 1
                 CALL "FR-VINE-STATE" USING WS-FACE WS-VINE
                 IF WS-VINE > 0
                     CALL "FL-SET-STATE" USING WS-NX WS-PY WS-NZ WS-VINE WS-FLAGS WS-OK
                     IF TD-KIND(L-ROW, L-SLOT) = 3
                         MOVE 0 TO WS-STOP
                         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4 OR WS-STOP = 1
                             COMPUTE WS-BELOW = WS-PY - WS-J
                             CALL "FL-GET-STATE" USING WS-NX WS-BELOW WS-NZ WS-STATE
                             CALL "FL-CLASS" USING WS-STATE WS-CLASS
                             IF WS-CLASS = 1
                                 CALL "FL-SET-STATE" USING WS-NX WS-BELOW WS-NZ WS-VINE WS-FLAGS WS-OK
                             ELSE
                                 MOVE 1 TO WS-STOP
                             END-IF
                         END-PERFORM
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-VINES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-COCOA.
*> USING state, row, slot: cocoa (3.3): one nextFloat() first, ended when it is not below the probability, ended without logs; then for each log of the three lowest layers (y at most the lowest
*> log's y + 2), for north, east, south, west one nextFloat(): at most 0.25 puts a cocoa pod, when the cell on the opposite side of the log is air, with age nextInt(3) (drawn then) and facing
*> that direction (the pod faces back at the log). The 12 states are age (0 to 2) times facing (north, south, west, east): index age * 4 + facing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:cocoa".
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-B
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-P
     CALL "FR-F32" USING WS-P
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     IF WS-F < WS-P AND TW-NLOG > 0 AND WS-B > 0
         IF CB-STATES(WS-B) = 12
             MOVE TW-LOG-Y(TW-LS(1)) TO WS-Y0
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
                 MOVE TW-LS(WS-I) TO WS-K
                 IF TW-LOG-Y(WS-K) - WS-Y0 <= 2
                     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
                         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                         MOVE TW-LOG-X(WS-K) TO WS-PX
                         MOVE TW-LOG-Z(WS-K) TO WS-PZ
*>                       d 0 north, 1 east, 2 south, 3 west: the pod faces d from the opposite side; facing index north 0, south 1, west 2, east 3
                         EVALUATE WS-D
                             WHEN 0
                                 ADD 1 TO WS-PZ
                                 MOVE 0 TO WS-FACING
                             WHEN 1
                                 SUBTRACT 1 FROM WS-PX
                                 MOVE 3 TO WS-FACING
                             WHEN 2
                                 SUBTRACT 1 FROM WS-PZ
                                 MOVE 1 TO WS-FACING
                             WHEN OTHER
                                 ADD 1 TO WS-PX
                                 MOVE 2 TO WS-FACING
                         END-EVALUATE
                         IF WS-F <= WS-QUARTER
                             CALL "FL-GET-STATE" USING WS-PX TW-LOG-Y(WS-K) WS-PZ WS-STATE
                             CALL "FL-CLASS" USING WS-STATE WS-CLASS
                             IF WS-CLASS = 1
                                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-AGE
                                 COMPUTE WS-STATE = CB-FIRST-STATE(WS-B) + WS-AGE * 4 + WS-FACING
                                 CALL "FL-SET-STATE" USING WS-PX TW-LOG-Y(WS-K) WS-PZ WS-STATE WS-FLAGS WS-OK
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-DEC-COCOA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DECORATE.
*> USING state, row, first slot, count: the decorators TR-DEC(row, first .. first + count - 1) in list order over the logs of the work area (sorted once, 3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-FIRST L-COUNT.
     CALL "FR-DEC-SORT"
     PERFORM VARYING WS-S FROM L-FIRST BY 1 UNTIL WS-S >= L-FIRST + L-COUNT
         EVALUATE TD-KIND(L-ROW, WS-S)
             WHEN 1
                 CALL "FR-DEC-LOGS" USING L-STATE L-ROW WS-S
             WHEN 2
             WHEN 3
                 CALL "FR-DEC-VINES" USING L-STATE L-ROW WS-S
             WHEN 4
                 CALL "FR-DEC-COCOA" USING L-STATE L-ROW WS-S
             WHEN 5
                 CALL "FR-DEC-BEEHIVE" USING L-STATE L-ROW WS-S
             WHEN 6
                 CALL "FR-DEC-ALTER" USING L-STATE L-ROW WS-S
             WHEN 7
                 CALL "FR-DEC-PLACE" USING L-STATE L-ROW WS-S
             WHEN 8
                 CALL "FR-DEC-SHELF" USING L-STATE L-ROW WS-S
             WHEN 9
                 CALL "FR-DEC-LEAVES" USING L-STATE L-ROW WS-S
             WHEN 10
                 CALL "FR-DEC-PALE" USING L-STATE L-ROW WS-S
             WHEN 11
                 CALL "FR-DEC-HEART" USING L-STATE L-ROW WS-S
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DECORATE.
