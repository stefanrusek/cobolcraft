*> The mount inventories (docs/protocol/40-menus-6-mount-inventories.md): the table of 5.1 and 5.2 (MOUNT-VARIANT), the Mount Screen Open packet (05a 0x2A, MOUNT-OPEN), which
*> slots are shown (MOUNT-SLOT-ACTIVE) and the frames and empty-slot icons of the screen (MOUNT-DECOR, called by MENU-DECOR). The menu is a container screen of the pseudo
*> menu type 100 + chest columns (the horse family) or 110 (the nautilus); its server rules (quick move, may place, still valid) are the server's.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOUNT-VARIANT.
*> USING entity type id (21 section 2), kind out (1 horse family, 2 nautilus), saddle slot shown out, body slot shown out, body icon out (1 horse armor, 2 llama armor, 3 nautilus
*> armor, 0 none), entity key out (PIC X(16)), known out (1/0): 5.2 for a tamed adult. A llama has no saddle slot (not in the tag can_equip_saddle), the donkey, mule and skeleton
*> horse no body slot (not in can_wear_horse_armor, not a llama).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
*>   Entity type (3 digits), kind, saddle, body, icon, key (16).
    05 FILLER PIC X(23) VALUE "0371100donkey          ".
    05 FILLER PIC X(23) VALUE "0671111horse           ".
    05 FILLER PIC X(23) VALUE "0791012llama           ".
    05 FILLER PIC X(23) VALUE "0881100mule            ".
    05 FILLER PIC X(23) VALUE "0892113nautilus        ".
    05 FILLER PIC X(23) VALUE "1191100skeleton_horse  ".
    05 FILLER PIC X(23) VALUE "1381012trader_llama    ".
    05 FILLER PIC X(23) VALUE "1551111zombie_horse    ".
    05 FILLER PIC X(23) VALUE "1562113zombie_nautilus ".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 9 TIMES.
       10 WS-R-TYPE        PIC 999.
       10 WS-R-KIND        PIC 9.
       10 WS-R-SADDLE      PIC 9.
       10 WS-R-BODY        PIC 9.
       10 WS-R-ICON        PIC 9.
       10 WS-R-KEY         PIC X(16).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SADDLE               BINARY-LONG.
 01 L-BODY                 BINARY-LONG.
 01 L-ICON                 BINARY-LONG.
 01 L-KEY                  PIC X(16).
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KIND L-SADDLE L-BODY L-ICON L-KEY L-KNOWN.
     MOVE 0 TO L-KIND L-SADDLE L-BODY L-ICON L-KNOWN
     MOVE SPACES TO L-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF WS-R-TYPE(WS-I) = L-TYPE
             MOVE WS-R-KIND(WS-I) TO L-KIND
             MOVE WS-R-SADDLE(WS-I) TO L-SADDLE
             MOVE WS-R-BODY(WS-I) TO L-BODY
             MOVE WS-R-ICON(WS-I) TO L-ICON
             MOVE WS-R-KEY(WS-I) TO L-KEY
             MOVE 1 TO L-KNOWN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOUNT-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOUNT-OPEN.
*> USING CLIENT-STATE, packet PB-BUFFER: Mount Screen Open (05a 0x2A): VarInt container id, VarInt chest columns, Int entity id. The entity must be tracked by the client and a
*> horse or nautilus type (3.3): the menu is then opened as the container screen of the pseudo type 100 + columns (the horse family, columns 0 to 5) or 110 (the nautilus, no chest);
*> the title is the entity type's name from the language; any other entity changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-COLUMNS             BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-ICON                BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-KNOWN               BINARY-LONG.
 01 WS-LANG-KEY            PIC X(80).
 01 WS-LANG-LENGTH         BINARY-LONG.
 01 WS-TITLE               PIC X(512).
 01 WS-TITLE-LENGTH        BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COLUMNS
     CALL "PB-GET-INT" USING PB-BUFFER WS-ENTITY
     IF PB-ERROR = 1 OR WS-CONTAINER <= 0 OR WS-COLUMNS < 0 OR WS-COLUMNS > 5
         GOBACK
     END-IF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = WS-ENTITY
             MOVE EN-TYPE(WS-I) TO WS-TYPE
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         GOBACK
     END-IF
     CALL "MOUNT-VARIANT" USING WS-TYPE WS-KIND WS-SADDLE WS-BODY WS-ICON WS-KEY WS-KNOWN
     IF WS-KNOWN = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-LANG-KEY
     STRING "entity.minecraft." FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-LANG-KEY
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LANG-KEY)) TO WS-LANG-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-LANG-KEY WS-LANG-LENGTH WS-TITLE WS-TITLE-LENGTH
     MOVE WS-TITLE(1:64) TO SM-CX-TITLE
     MOVE FUNCTION MIN(WS-TITLE-LENGTH, 64) TO SM-CX-TITLE-LENGTH
     MOVE WS-CONTAINER TO BM-ID
     MOVE 0 TO BM-STATE-ID
     IF WS-KIND = 2
         MOVE 110 TO BM-TYPE
     ELSE
         COMPUTE BM-TYPE = 100 + WS-COLUMNS
     END-IF
     MOVE WS-ENTITY TO MT-ENTITY
     MOVE WS-KIND TO MT-KIND
     MOVE WS-SADDLE TO MT-SADDLE
     MOVE WS-BODY TO MT-BODY
     MOVE WS-ICON TO MT-ICON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO BX-COUNT(WS-I) BX-ITEM(WS-I) BX-DAMAGE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO BM-DATA(WS-I)
     END-PERFORM
     CALL "CX-RESET" USING CLIENT-STATE
     MOVE SCR-CONTAINER TO WS-ARG
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ARG
     GOBACK.
 END PROGRAM MOUNT-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOUNT-SLOT-ACTIVE.
*> USING CLIENT-STATE, own slot index, active out (1/0): the saddle slot (0) and the body slot (1) are active when the mount type shows them (2.4); the chest slots always.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-ACTIVE.
     MOVE 1 TO L-ACTIVE
     IF L-SLOT = 0
         MOVE MT-SADDLE TO L-ACTIVE
     END-IF
     IF L-SLOT = 1
         MOVE MT-BODY TO L-ACTIVE
     END-IF
     GOBACK.
 END PROGRAM MOUNT-SLOT-ACTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOUNT-DECOR.
*> USING CLIENT-STATE, left, top: 6.2: the chest area (a swatch for the sprite container/horse/chest_slots, 18 x columns by 54 at (79, 17), only with columns above 0), the
*> saddle frame (18 x 18 at (7, 17)) and the body frame (7, 35) of the active slots, then the empty-slot icon (16 x 16 at the slot's item cell, a swatch for the sprite) of each
*> active slot with no item. The entity preview (6.4) is not drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-COLUMNS             BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-OVERLAY.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP.
     MOVE SPACES TO WS-TEXT
     COMPUTE WS-COLUMNS = FUNCTION MAX(BM-TYPE - 100, 0)
     IF WS-COLUMNS > 5
         MOVE 0 TO WS-COLUMNS
     END-IF
     IF WS-COLUMNS > 0
         COMPUTE WS-X = L-LEFT + 79
         COMPUTE WS-Y = L-TOP + 17
         COMPUTE WS-W = 18 * WS-COLUMNS
         MOVE 54 TO WS-H
         MOVE SW-BUTTON TO WS-SWATCH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     END-IF
     MOVE 18 TO WS-W WS-H
     COMPUTE WS-X = L-LEFT + 7
     MOVE SW-BUTTON TO WS-SWATCH
     IF MT-SADDLE = 1
         COMPUTE WS-Y = L-TOP + 17
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     END-IF
     IF MT-BODY = 1
         COMPUTE WS-Y = L-TOP + 35
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     END-IF
     MOVE 16 TO WS-W WS-H
     COMPUTE WS-X = L-LEFT + 8
     MOVE SW-PANEL TO WS-SWATCH
     IF MT-SADDLE = 1 AND BX-COUNT(1) = 0
         COMPUTE WS-Y = L-TOP + 18
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     END-IF
     IF MT-BODY = 1 AND BX-COUNT(2) = 0
         COMPUTE WS-Y = L-TOP + 36
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     END-IF
     GOBACK.
 END PROGRAM MOUNT-DECOR.
