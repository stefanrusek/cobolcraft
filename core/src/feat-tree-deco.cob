*> The tree decorators (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 3): FD-DECO-NODE compiles one decorator object into a slot TR-DEC of a feature row, FR-DECORATE
*> runs the decorators of a slot range over the logs of the work area of TREEWORK.cpy (TW-LOG) in the order of the decorator context (3.1: the list sorted by y, stable; positions of the same y
*> keep the order they were placed in, where the game keeps the order of its hash set, Open question 1 there), with the draws in the doc's order.
*> Supported here: attached_to_logs (3.3, used by the fallen trees).
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
     IF WS-TEXT(1:26) = "minecraft:attached_to_logs"
         MOVE 1 TO TD-KIND(L-ROW, L-SLOT)
         CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TD-PROB(L-ROW, L-SLOT)
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-PROVIDER WS-E
         CALL "FD-PROV-NODE" USING JSON-DOC WS-E TD-PV(L-ROW, L-SLOT)
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
     END-IF
     GOBACK.
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
         IF TD-KIND(L-ROW, WS-S) = 1
             CALL "FR-DEC-LOGS" USING L-STATE L-ROW WS-S
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DECORATE.
