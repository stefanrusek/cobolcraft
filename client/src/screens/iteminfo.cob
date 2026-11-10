*> Item facts for the screens: from the content registry when a set is open (the built-in set of the cobolcraft world type, the standard set of a network game), else from the
*> 18-item stand-in table of CLCONST (CL-ITEMS). CL-ITEM-COUNT-NOW is the number of items of that source.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-ITEM-INFO.
*> USING CLIENT-STATE, item id, namespace out (PIC X(16)), path out (PIC X(40)), maximum stack size out, places a block out (1/0), tool class out (PIC X: H the pickaxe and axe
*> rules, S the shovel rule, space none), food out (the nutrition; 0 none), known out (1/0). The content row's class BlockItem places a block; its components summary holds "tool
*> #minecraft:mineable/<kind> ..." for a tool and "food <nutrition>" for a food.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ROW                 PIC X(270).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-KEY              PIC X(38).
    05 WS-CLASS            PIC X(24).
    05 FILLER              PIC X(4).
    05 WS-STACK            PIC X(2).
    05 FILLER              PIC X(38).
    05 WS-COMP             PIC X(160).
 01 WS-STATUS              BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NUM                 PIC X(8).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-NS                   PIC X(16).
 01 L-PATH                 PIC X(40).
 01 L-MAX                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-TOOL                 PIC X.
 01 L-FOOD                 BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-NS L-PATH L-MAX L-BLOCK L-TOOL L-FOOD L-KNOWN.
     MOVE SPACES TO L-NS L-PATH L-TOOL
     MOVE 0 TO L-MAX L-BLOCK L-FOOD L-KNOWN
     CALL "CONTENT-ITEM-BY-ID" USING L-ITEM WS-ROW WS-STATUS
     IF WS-STATUS = 0
         MOVE 1 TO L-KNOWN
         MOVE 0 TO WS-POS
         INSPECT WS-KEY TALLYING WS-POS FOR ALL ":"
         IF WS-POS > 0
             UNSTRING WS-KEY DELIMITED BY ":" INTO L-NS L-PATH
         ELSE
             MOVE "minecraft" TO L-NS
             MOVE WS-KEY TO L-PATH
         END-IF
         IF WS-STACK NOT = SPACES
             MOVE FUNCTION NUMVAL(WS-STACK) TO L-MAX
         END-IF
         IF WS-CLASS(1:9) = "BlockItem"
             MOVE 1 TO L-BLOCK
         END-IF
         MOVE 0 TO WS-POS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
             IF WS-COMP(WS-I:5) = "tool " AND WS-POS = 0
                 MOVE WS-I TO WS-POS
             END-IF
         END-PERFORM
         IF WS-POS > 0
             MOVE "H" TO L-TOOL
             PERFORM VARYING WS-I FROM WS-POS BY 1 UNTIL WS-I > 150
                 IF WS-COMP(WS-I:6) = "shovel"
                     MOVE "S" TO L-TOOL
                 END-IF
             END-PERFORM
         END-IF
         MOVE 0 TO WS-POS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
             IF WS-COMP(WS-I:5) = "food " AND WS-POS = 0
                 MOVE WS-I TO WS-POS
             END-IF
         END-PERFORM
         IF WS-POS > 0
             MOVE SPACES TO WS-NUM
             UNSTRING WS-COMP(WS-POS + 5:) DELIMITED BY "," OR SPACE INTO WS-NUM
             MOVE FUNCTION NUMVAL(WS-NUM) TO L-FOOD
         END-IF
     ELSE
         IF WS-STATUS = 4 AND L-ITEM >= 0 AND L-ITEM < CL-ITEM-COUNT
             MOVE 1 TO L-KNOWN
             MOVE "cobolcraft" TO L-NS
             MOVE CL-IT-KEY(L-ITEM + 1) TO L-PATH
             MOVE CL-IT-MAX(L-ITEM + 1) TO L-MAX
             IF CL-IT-STATE(L-ITEM + 1) > 0
                 MOVE 1 TO L-BLOCK
             END-IF
             MOVE CL-IT-TOOL(L-ITEM + 1) TO L-TOOL
             MOVE CL-IT-FOOD(L-ITEM + 1) TO L-FOOD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CL-ITEM-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-ITEM-COUNT-NOW.
*> USING count out: the items of the open content set, else of the stand-in table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ROW                 PIC X(270).
 01 WS-ID                  BINARY-LONG VALUE 0.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE CL-ITEM-COUNT TO L-COUNT
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     IF WS-STATUS = 0
         CALL "ITEM-ROW-AT" USING WS-ID WS-ROW WS-STATUS L-COUNT
     END-IF
     GOBACK.
 END PROGRAM CL-ITEM-COUNT-NOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-ITEM-FLAGS.
*> USING CLIENT-STATE, item id, places a block out (1/0), tool class out (PIC X), food out: the facts the controls and the hand need, from CL-ITEM-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ITEM                BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-TOOL                 PIC X.
 01 L-FOOD                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-BLOCK L-TOOL L-FOOD.
     MOVE L-ITEM TO WS-ITEM
     CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX L-BLOCK L-TOOL L-FOOD WS-KNOWN
     GOBACK.
 END PROGRAM CL-ITEM-FLAGS.
