*> The cartography table as a live station menu (docs/protocol/40-menus-4 section 5, 25-5 section 8; lane p70c, T23501): station kind 6, MN-CFAMILY 26; own slots 0 the map, 1 the additional item
*> (MN-WSLOT 1 and 2), own slot 2 the result (MN-RESULT-*, MN-WRES 2); no data slot. The map slot takes a stack with a map_id, the additional slot paper, the empty map or a glass pane. The saved data
*> of a map is the store of maps.cob (scale, locked). The result of paper is the map with map_post_processing SCALE (when its item is in the tag extendable_maps, it is unlocked and below scale 4),
*> of a glass pane the map with LOCK (unlocked map), of the empty map two copies; the post-processing runs when the result is taken (onCraftedBy, MENU-RESULT-PRE: a new saved map, the id replaced).
*>   CARTO-KIND USING item, kind out                 1 paper, 2 the empty map, 3 glass pane, 0 any other item
*>   MENU-CARTO-MAYPLACE USING own slot, item, handle, ok out   mayPlace of 5.2
*>   MENU-CARTO-UPDATE USING row                     slotsChanged and setupResultSlot (5.3)
*>   MENU-CARTO-POST USING row                       onCraftedPostProcess of the result stack (5.4 step 2)
*>   MENU-RESULT-PRE USING row                       called before a result slot is taken: the post-processing of the cartography table's result
*>   MENU-CARTO-TAKEN USING row                      onTake (5.4 step 1): one map and one additional item are used, the result is made again
*>   MENU-CARTO-QUICK USING row, menu slot, item out, count out   quickMoveStack (5.5)
*> Gaps: UI_CARTOGRAPHY_TABLE_TAKE_RESULT is not played (40-4 open question 9); the creative clone of a result (safeClone) is not post-processed; the saved maps are not written to disk (the layout of
*> data/map_<id>.dat and idcounts.dat is in no document: 25-5 section 8.2 lists fields only).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CARTO-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-KIND.
     MOVE 0 TO L-KIND
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     EVALUATE WS-BARE
         WHEN "paper"
             MOVE 1 TO L-KIND
         WHEN "map"
             MOVE 2 TO L-KIND
         WHEN "glass_pane"
             MOVE 3 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM CARTO-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CARTO-MAYPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-PAPER               BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-GLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ITEM L-HANDLE L-OK.
     CALL "SC-MAPID-GET" USING L-HANDLE WS-ID WS-HAS
     CALL "CARTO-KIND" USING L-ITEM WS-KIND
     MOVE 0 TO WS-PAPER WS-EMPTY WS-GLASS
     IF WS-KIND = 1
         MOVE 1 TO WS-PAPER
     END-IF
     IF WS-KIND = 2
         MOVE 1 TO WS-EMPTY
     END-IF
     IF WS-KIND = 3
         MOVE 1 TO WS-GLASS
     END-IF
     CALL "MN4-CARTO-MAYPLACE" USING L-SLOT WS-HAS WS-PAPER WS-EMPTY WS-GLASS L-OK
     GOBACK.
 END PROGRAM MENU-CARTO-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CARTO-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-RH                  BINARY-LONG.
 01 WS-ME                  BINARY-LONG.
 01 WS-EE                  BINARY-LONG.
 01 WS-ACT                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-LOCKED              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EXT                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-POST                BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:extendable_maps".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-RH WS-ME WS-EE
     IF MN-RESULT-COUNT(L-ROW) > 0
         MOVE 1 TO WS-RH
     END-IF
     IF MN-WSLOT-COUNT(L-ROW, 1) = 0
         MOVE 1 TO WS-ME
     END-IF
     IF MN-WSLOT-COUNT(L-ROW, 2) = 0
         MOVE 1 TO WS-EE
     END-IF
     CALL "MN4-CARTO-CHANGED" USING WS-RH WS-ME WS-EE WS-ACT
     IF WS-ACT = 1
         MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW) MN-RESULT-VAR(L-ROW)
     END-IF
     IF WS-ACT = 2
         CALL "SC-MAPID-GET" USING MN-WSLOT-VAR(L-ROW, 1) WS-ID WS-HAS
         MOVE 0 TO WS-FOUND
         IF WS-HAS = 1
             CALL "MAP-FIND" USING WS-ID WS-SCALE WS-LOCKED WS-CX WS-CZ WS-DIM WS-FOUND
         END-IF
         CALL "CARTO-KIND" USING MN-WSLOT-ITEM(L-ROW, 2) WS-KIND
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG MN-WSLOT-ITEM(L-ROW, 1) WS-EXT
         CALL "MN4-CARTO-SETUP" USING WS-KIND WS-EXT WS-LOCKED WS-SCALE WS-FOUND WS-ACT WS-COUNT WS-POST
*>       Nothing changes for a map without data (a stale result stays); an unfit paper or pane removes the result.
         IF WS-ACT = 1
             MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW) MN-RESULT-VAR(L-ROW)
         END-IF
         IF WS-ACT = 2
             MOVE MN-WSLOT-VAR(L-ROW, 1) TO WS-HANDLE
             IF WS-POST > 0
                 COMPUTE WS-MODE = FUNCTION MOD(WS-POST, 2)
                 CALL "SC-MAPPOST-SET" USING WS-HANDLE WS-MODE
             END-IF
             MOVE MN-WSLOT-ITEM(L-ROW, 1) TO MN-RESULT-ITEM(L-ROW)
             MOVE WS-COUNT TO MN-RESULT-COUNT(L-ROW)
             MOVE WS-HANDLE TO MN-RESULT-VAR(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-CARTO-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CARTO-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-TYPE                BINARY-LONG VALUE 50.
 01 WS-MODE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-HOW                 BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SC-MAPPOST-GET" USING MN-RESULT-VAR(L-ROW) WS-MODE
     IF WS-MODE < 0
         GOBACK
     END-IF
*>   LOCK (0) makes a locked copy, SCALE (1) a scaled map; either way the stack gets the new id and loses the component.
     CALL "SC-MAPID-GET" USING MN-RESULT-VAR(L-ROW) WS-ID WS-HAS
     COMPUTE WS-HOW = 2 - WS-MODE
     CALL "MAP-DERIVE" USING WS-ID WS-HOW WS-NEW
     MOVE MN-RESULT-VAR(L-ROW) TO WS-HANDLE
     CALL "SC-COMP-DROP" USING WS-HANDLE WS-TYPE
     IF WS-NEW >= 0
         CALL "SC-MAPID-SET" USING WS-HANDLE WS-NEW
     END-IF
     MOVE WS-HANDLE TO MN-RESULT-VAR(L-ROW)
     GOBACK.
 END PROGRAM MENU-CARTO-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-RESULT-PRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-WINDOW(L-ROW) > 0 AND MN-CFAMILY(L-ROW) = 26
         CALL "MENU-CARTO-POST" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM MENU-RESULT-PRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CARTO-TAKEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-MC                  BINARY-LONG.
 01 WS-AC                  BINARY-LONG.
 01 WS-NM                  BINARY-LONG.
 01 WS-NA                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE MN-WSLOT-COUNT(L-ROW, 1) TO WS-MC
     MOVE MN-WSLOT-COUNT(L-ROW, 2) TO WS-AC
     CALL "MN4-CARTO-TAKE" USING WS-MC WS-AC WS-NM WS-NA
     MOVE WS-NM TO MN-WSLOT-COUNT(L-ROW, 1)
     MOVE WS-NA TO MN-WSLOT-COUNT(L-ROW, 2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         IF MN-WSLOT-COUNT(L-ROW, WS-I) = 0
             MOVE 0 TO MN-WSLOT-ITEM(L-ROW, WS-I) MN-WSLOT-VAR(L-ROW, WS-I)
         END-IF
     END-PERFORM
     CALL "MENU-STATION-UPDATE" USING L-ROW
     GOBACK.
 END PROGRAM MENU-CARTO-TAKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CARTO-QUICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-PMG                 BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REV                 BINARY-LONG.
 01 WS-ONQ                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
*>   The result is post-processed (onCraftedBy) before it is moved, so the stack that moves is the finished one.
     IF L-SLOT = 2
         CALL "MENU-CARTO-POST" USING L-ROW
         CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     END-IF
     CALL "SC-MAPID-GET" USING WS-VAR WS-ID WS-HAS
     CALL "CARTO-KIND" USING WS-ITEM WS-KIND
     MOVE 0 TO WS-PMG
     IF WS-KIND > 0
         MOVE 1 TO WS-PMG
     END-IF
     CALL "MN4-CARTO-QUICK" USING L-SLOT WS-HAS WS-PMG WS-RULE WS-FIRST WS-END WS-REV WS-ONQ
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REV WS-MOVED WS-VAR
     IF WS-MOVED = 0
         GOBACK
     END-IF
     IF L-SLOT = 2
         IF WS-LEFT > 0
             CALL "GI-THROW-STACK-X" USING L-ROW WS-ITEM WS-LEFT WS-VAR
         END-IF
         CALL "MENU-SET-X" USING L-ROW L-SLOT WS-ITEM WS-ZERO WS-VAR
         CALL "MENU-STATION-TAKEN" USING L-ROW
         MOVE WS-ITEM TO L-RET-ITEM
         MOVE WS-COUNT TO L-RET-COUNT
     ELSE
         CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     END-IF
     GOBACK.
 END PROGRAM MENU-CARTO-QUICK.
