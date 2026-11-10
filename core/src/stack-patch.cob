*> Item stacks with data components in the core (T3650 to T3652; docs/protocol/00 section 12.1 and 12.2, 17 section 1.1 and 1.2;
*> core/copy/CSTACK.cpy): a stack is an item id, a count and a handle of the patch pool (0: no component differs from the item's
*> prototype). The slots of the player rows, the menus and the cursor keep the handle beside the item and the count (the -VAR
*> fields), so a damaged, named or enchanted item is moved, merged (equal item and handle only), split and shown as the wire
*> stack of PB-PUT-ITEM-STACK. Only the representation and the wire round trip are here: what damage, a name or an
*> enchantment do belongs to the phases that use them.
*>
*> Typed readers and writers for the components of 17 section 1.2 that gameplay needs: damage (3), max_damage (2),
*> custom_name (6), enchantments (13); every other component the wire can carry is kept as bytes (SP-GET-COMPONENT,
*> SP-SET-COMPONENT). The defaults come from the content item components (CONTENT-ITEM-COMPONENT).
*>
*> Entry points:
*>   SP-INTERN USING PB-ITEMSTACK-X, handle out        the patch of a wire stack as a handle (0 when it is empty)
*>   SP-EXPORT USING item, count, handle, PB-ITEMSTACK-X out    the wire stack (count 0 is the empty stack)
*>   SP-GET-COMPONENT USING handle, type, value out (X(64)), length out, found out (1 or 0)
*>   SP-SET-COMPONENT USING handle in and out, type, value (X(64)), length   adds or replaces one component
*>   SP-GET-DAMAGE USING item, handle, damage out; SP-SET-DAMAGE USING handle in and out, damage
*>   SP-GET-MAX-DAMAGE USING item, handle, max damage out (patch, else the content's, else 0)
*>   SP-SET-NAME USING handle in and out, name (X(64)), length; SP-GET-NAME USING handle, name out, length out (0: none)
*>   SP-ADD-ENCHANT USING handle in and out, enchantment id, level; SP-ENCHANT-LEVEL USING handle, id, level out (0: none)
*>   SP-SWEEP                                          frees the entries no player slot refers to

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-SWEEP.
*> Frees every pool entry that no slot, grid, result or cursor of a player in the world refers to.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CSTACK.
 01 WS-MARKS.
    05 WS-MARK             BINARY-LONG OCCURS 512 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 512
         MOVE 0 TO WS-MARK(WS-I)
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 64
         IF PL-USED(WS-ROW) = 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
                 MOVE PL-SLOT-VAR(WS-ROW, WS-I) TO WS-V
                 CALL "SP-MARK" USING WS-MARKS WS-V
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
                 MOVE MN-EQUIP-VAR(WS-ROW, WS-I) TO WS-V
                 CALL "SP-MARK" USING WS-MARKS WS-V
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MN-IGRID-VAR(WS-ROW, WS-I) TO WS-V
                 CALL "SP-MARK" USING WS-MARKS WS-V
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
                 MOVE MN-BGRID-VAR(WS-ROW, WS-I) TO WS-V
                 CALL "SP-MARK" USING WS-MARKS WS-V
             END-PERFORM
             MOVE PL-CARRIED-VAR(WS-ROW) TO WS-V
             CALL "SP-MARK" USING WS-MARKS WS-V
         END-IF
     END-PERFORM
     CALL "BE-MARK-PATCHES" USING WS-MARKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 512
         IF WS-MARK(WS-I) = 0
             MOVE 0 TO SP-LIVE(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-SWEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-MARK.
*> USING marks (512 BINARY-LONG), handle: marks the entry the handle names (a handle outside 1 to 512 names none).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MARKS.
    05 L-MARK              BINARY-LONG OCCURS 512 TIMES.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-MARKS L-HANDLE.
     IF L-HANDLE >= 1 AND L-HANDLE <= 512
         MOVE 1 TO L-MARK(L-HANDLE)
     END-IF
     GOBACK.
 END PROGRAM SP-MARK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-INTERN-TEMP.
*> USING a canonical patch (CSTACKE layout), handle out: the entry equal to it, else a new entry (after a sweep when the pool
*> is full), else 0 (the pool is full of entries in use). An empty patch is handle 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CSTACK.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEMP.
    05 LT-ENTRY.
       COPY CSTACKE REPLACING LEADING ==SP-== BY ==LT-==.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEMP L-HANDLE.
     MOVE 0 TO L-HANDLE
     IF LT-ADDED-COUNT = 0 AND LT-REMOVED-COUNT = 0
         GOBACK
     END-IF
     MOVE 1 TO LT-LIVE
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2 OR L-HANDLE > 0
         MOVE 0 TO WS-FREE
         PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 512 OR L-HANDLE > 0
             IF SP-LIVE(WS-H) = 0
                 IF WS-FREE = 0
                     MOVE WS-H TO WS-FREE
                 END-IF
             ELSE
                 MOVE 0 TO WS-SAME
                 IF SP-ADDED-COUNT(WS-H) = LT-ADDED-COUNT AND SP-REMOVED-COUNT(WS-H) = LT-REMOVED-COUNT
                     MOVE 1 TO WS-SAME
                 END-IF
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LT-ADDED-COUNT OR WS-SAME = 0
                     IF SP-TYPE(WS-H, WS-I) NOT = LT-TYPE(WS-I) OR SP-LENGTH(WS-H, WS-I) NOT = LT-LENGTH(WS-I)
                             OR SP-VALUE(WS-H, WS-I) NOT = LT-VALUE(WS-I)
                         MOVE 0 TO WS-SAME
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LT-REMOVED-COUNT OR WS-SAME = 0
                     IF SP-REMOVED(WS-H, WS-I) NOT = LT-REMOVED(WS-I)
                         MOVE 0 TO WS-SAME
                     END-IF
                 END-PERFORM
                 IF WS-SAME = 1
                     MOVE WS-H TO L-HANDLE
                 END-IF
             END-IF
         END-PERFORM
         IF L-HANDLE = 0
             IF WS-FREE > 0
                 MOVE LT-ENTRY TO SP-ENTRY(WS-FREE)
                 MOVE WS-FREE TO L-HANDLE
             ELSE
                 IF WS-PASS = 1
                     CALL "SP-SWEEP"
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-INTERN-TEMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-INTERN.
*> USING PB-ITEMSTACK-X, handle out: the canonical patch of the wire stack's DataComponentPatch (sorted, without repeats, the
*> damage 0 left out; an added component of more than SP-VALUE-MAX value bytes, and the components past the eighth added or
*> removed, are dropped), interned. The stack's item and count are not part of it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T.
    05 TP-ENTRY.
       COPY CSTACKE REPLACING LEADING ==SP-== BY ==TP-==.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING PB-ITEMSTACK-X L-HANDLE.
     INITIALIZE WS-T
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-ADDED-COUNT
         MOVE PB-ISX-TYPE(WS-I) TO WS-TYPE
         MOVE PB-ISX-VALUE-LENGTH(WS-I) TO WS-LEN
         IF WS-LEN <= 64 AND NOT (WS-TYPE = 3 AND WS-LEN = 1 AND PB-ISX-VALUE(WS-I)(1:1) = X"00")
             MOVE 1 TO WS-J
             PERFORM UNTIL WS-J > TP-ADDED-COUNT OR TP-TYPE(WS-J) >= WS-TYPE
                 ADD 1 TO WS-J
             END-PERFORM
             IF WS-J > TP-ADDED-COUNT OR TP-TYPE(WS-J) NOT = WS-TYPE
                 IF TP-ADDED-COUNT < 8
                     PERFORM VARYING WS-K FROM TP-ADDED-COUNT BY -1 UNTIL WS-K < WS-J
                         MOVE TP-ADDED(WS-K) TO TP-ADDED(WS-K + 1)
                     END-PERFORM
                     ADD 1 TO TP-ADDED-COUNT
                 ELSE
                     MOVE 0 TO WS-J
                 END-IF
             END-IF
             IF WS-J > 0
                 MOVE WS-TYPE TO TP-TYPE(WS-J)
                 MOVE WS-LEN TO TP-LENGTH(WS-J)
                 MOVE SPACES TO TP-VALUE(WS-J)
                 IF WS-LEN > 0
                     MOVE PB-ISX-VALUE(WS-I)(1:WS-LEN) TO TP-VALUE(WS-J)(1:WS-LEN)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-REMOVED-COUNT
         MOVE PB-ISX-REMOVED(WS-I) TO WS-TYPE
         MOVE 1 TO WS-J
         PERFORM UNTIL WS-J > TP-REMOVED-COUNT OR TP-REMOVED(WS-J) >= WS-TYPE
             ADD 1 TO WS-J
         END-PERFORM
         IF (WS-J > TP-REMOVED-COUNT OR TP-REMOVED(WS-J) NOT = WS-TYPE) AND TP-REMOVED-COUNT < 8
             PERFORM VARYING WS-K FROM TP-REMOVED-COUNT BY -1 UNTIL WS-K < WS-J
                 MOVE TP-REMOVED(WS-K) TO TP-REMOVED(WS-K + 1)
             END-PERFORM
             ADD 1 TO TP-REMOVED-COUNT
             MOVE WS-TYPE TO TP-REMOVED(WS-J)
         END-IF
     END-PERFORM
     CALL "SP-INTERN-TEMP" USING WS-T L-HANDLE
     GOBACK.
 END PROGRAM SP-INTERN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-EXPORT.
*> USING item, count, handle, PB-ITEMSTACK-X out: the wire stack of an item, a count and a patch handle. A count of 0 or less
*> is the empty stack. A handle that is 0, outside 1 to 512 or not in use has no components.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CSTACK.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ITEM L-COUNT L-HANDLE PB-ITEMSTACK-X.
     IF L-COUNT <= 0
         MOVE 0 TO PB-ISX-COUNT PB-ISX-ITEM PB-ISX-ADDED-COUNT PB-ISX-REMOVED-COUNT
         GOBACK
     END-IF
     MOVE L-COUNT TO PB-ISX-COUNT
     MOVE L-ITEM TO PB-ISX-ITEM
     MOVE 0 TO PB-ISX-ADDED-COUNT PB-ISX-REMOVED-COUNT
     IF L-HANDLE >= 1 AND L-HANDLE <= 512
         IF SP-LIVE(L-HANDLE) = 1
             MOVE SP-ADDED-COUNT(L-HANDLE) TO PB-ISX-ADDED-COUNT
             MOVE SP-REMOVED-COUNT(L-HANDLE) TO PB-ISX-REMOVED-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-ADDED-COUNT(L-HANDLE)
                 MOVE SP-TYPE(L-HANDLE, WS-I) TO PB-ISX-TYPE(WS-I)
                 MOVE SP-LENGTH(L-HANDLE, WS-I) TO WS-LEN PB-ISX-VALUE-LENGTH(WS-I)
                 IF WS-LEN > 0
                     MOVE SP-VALUE(L-HANDLE, WS-I)(1:WS-LEN) TO PB-ISX-VALUE(WS-I)(1:WS-LEN)
                 END-IF
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-REMOVED-COUNT(L-HANDLE)
                 MOVE SP-REMOVED(L-HANDLE, WS-I) TO PB-ISX-REMOVED(WS-I)
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SP-EXPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-GET-COMPONENT.
*> USING handle, component type, value out (PIC X(64), space padded), length out, found out (1 when the patch adds the
*> component, else 0 with length 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CSTACK.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-VALUE                PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-TYPE L-VALUE L-LENGTH L-FOUND.
     MOVE SPACES TO L-VALUE
     MOVE 0 TO L-LENGTH L-FOUND
     IF L-HANDLE >= 1 AND L-HANDLE <= 512
         IF SP-LIVE(L-HANDLE) = 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-ADDED-COUNT(L-HANDLE)
                 IF SP-TYPE(L-HANDLE, WS-I) = L-TYPE
                     MOVE SP-VALUE(L-HANDLE, WS-I) TO L-VALUE
                     MOVE SP-LENGTH(L-HANDLE, WS-I) TO L-LENGTH
                     MOVE 1 TO L-FOUND
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SP-GET-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-SET-COMPONENT.
*> USING handle (in and out), component type, value (PIC X(64)), length: the patch with the component added (replacing an
*> added one of that type, and taken out of the removed list), interned; the new handle replaces the old one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SX-==.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ONE-ITEM            BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-VALUE                PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-TYPE L-VALUE L-LENGTH.
     CALL "SP-EXPORT" USING WS-ONE-ITEM WS-ONE L-HANDLE SX-ITEMSTACK-X
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SX-ISX-ADDED-COUNT
         IF SX-ISX-TYPE(WS-I) = L-TYPE
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT = 0
         ADD 1 TO SX-ISX-ADDED-COUNT
         MOVE SX-ISX-ADDED-COUNT TO WS-AT
     END-IF
     MOVE L-TYPE TO SX-ISX-TYPE(WS-AT)
     MOVE L-LENGTH TO SX-ISX-VALUE-LENGTH(WS-AT)
     MOVE L-VALUE TO SX-ISX-VALUE(WS-AT)
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SX-ISX-REMOVED-COUNT
         IF SX-ISX-REMOVED(WS-I) NOT = L-TYPE
             ADD 1 TO WS-J
             MOVE SX-ISX-REMOVED(WS-I) TO SX-ISX-REMOVED(WS-J)
         END-IF
     END-PERFORM
     MOVE WS-J TO SX-ISX-REMOVED-COUNT
     CALL "SP-INTERN" USING SX-ITEMSTACK-X L-HANDLE
     GOBACK.
 END PROGRAM SP-SET-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-VARINT-PUT.
*> USING value (PIC X(64)), position (in and out: the next byte, 1 based), number (0 or more): appends the VarInt.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                PIC X(64).
 01 L-POS                  BINARY-LONG.
 01 L-NUMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-POS L-NUMBER.
     MOVE L-NUMBER TO WS-N
     PERFORM UNTIL WS-N < 128
         COMPUTE WS-B = FUNCTION MOD(WS-N, 128) + 128
         MOVE FUNCTION CHAR(WS-B + 1) TO L-VALUE(L-POS:1)
         ADD 1 TO L-POS
         COMPUTE WS-N = WS-N / 128
     END-PERFORM
     MOVE FUNCTION CHAR(WS-N + 1) TO L-VALUE(L-POS:1)
     ADD 1 TO L-POS
     GOBACK.
 END PROGRAM SP-VARINT-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-VARINT-GET.
*> USING value (PIC X(64)), position (in and out: the next byte, 1 based), number out: reads a VarInt (stops at the end of the value or after four bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-LONG.
 01 WS-MUL                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                PIC X(64).
 01 L-POS                  BINARY-LONG.
 01 L-NUMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-POS L-NUMBER.
     MOVE 0 TO L-NUMBER WS-DONE
     MOVE 1 TO WS-MUL
     PERFORM UNTIL WS-DONE = 1
         IF L-POS > 64 OR WS-MUL > 16777216
             MOVE 1 TO WS-DONE
         ELSE
             COMPUTE WS-B = FUNCTION ORD(L-VALUE(L-POS:1)) - 1
             ADD 1 TO L-POS
             IF WS-B >= 128
                 COMPUTE L-NUMBER = L-NUMBER + (WS-B - 128) * WS-MUL
                 COMPUTE WS-MUL = WS-MUL * 128
             ELSE
                 COMPUTE L-NUMBER = L-NUMBER + WS-B * WS-MUL
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-VARINT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-GET-DAMAGE.
*> USING item, handle, damage out: the damage component (3), else 0 (17 section 1.1: the prototype value).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 3.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-HANDLE L-DAMAGE.
     MOVE 0 TO L-DAMAGE
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM SP-GET-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-SET-DAMAGE.
*> USING handle (in and out), damage (0 or more): the patch with the damage component (a damage of 0 leaves it out).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 3.
 01 WS-VALUE               PIC X(64).
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-DAMAGE.
     MOVE SPACES TO WS-VALUE
     MOVE 1 TO WS-POS
     CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS L-DAMAGE
     SUBTRACT 1 FROM WS-POS
     CALL "SP-SET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-POS
     GOBACK.
 END PROGRAM SP-SET-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-GET-MAX-DAMAGE.
*> USING item, handle, max damage out: the max_damage component (2) of the patch, else the item's max_damage of the content
*> item components, else 0 (an item without durability).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-NAME                PIC X(32) VALUE "max_damage".
 01 WS-TEXT                PIC X(100).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-HANDLE L-MAX.
     MOVE 0 TO L-MAX
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS L-MAX
     ELSE
         CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-TEXT WS-STATUS
         IF WS-STATUS = 0
             COMPUTE L-MAX = FUNCTION NUMVAL(WS-TEXT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SP-GET-MAX-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-SET-NAME.
*> USING handle (in and out), name (PIC X(64)), length (1 to 60): the custom_name component (6) as the network NBT string
*> tag of 00 section 9 (tag byte 8, UShort length, the bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 6.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-NAME L-LENGTH.
     MOVE SPACES TO WS-VALUE
     MOVE FUNCTION CHAR(9) TO WS-VALUE(1:1)
     MOVE FUNCTION CHAR(1) TO WS-VALUE(2:1)
     MOVE FUNCTION CHAR(L-LENGTH + 1) TO WS-VALUE(3:1)
     MOVE L-NAME(1:L-LENGTH) TO WS-VALUE(4:L-LENGTH)
     COMPUTE WS-LENGTH = L-LENGTH + 3
     CALL "SP-SET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     GOBACK.
 END PROGRAM SP-SET-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-GET-NAME.
*> USING handle, name out (PIC X(64)), length out: the plain string of the custom_name component, length 0 and spaces when
*> there is none or it is not a plain string tag of 1 to 60 bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 6.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-LENGTH
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1 AND WS-LENGTH >= 4 AND WS-VALUE(1:1) = FUNCTION CHAR(9)
         COMPUTE WS-N = FUNCTION ORD(WS-VALUE(3:1)) - 1
         IF WS-N >= 1 AND WS-N <= WS-LENGTH - 3
             MOVE WS-N TO L-LENGTH
             MOVE WS-VALUE(4:WS-N) TO L-NAME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SP-GET-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-ENCHANT-LEVEL.
*> USING handle, enchantment id, level out: the level of the enchantment in the enchantments component (13: VarInt count,
*> then VarInt enchantment id and VarInt level pairs), 0 when the stack does not have it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 13.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-ID L-LEVEL.
     MOVE 0 TO L-LEVEL
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-POS > 63
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-ID
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-LEVEL
             IF WS-ID = L-ID
                 MOVE WS-LEVEL TO L-LEVEL
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SP-ENCHANT-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-ADD-ENCHANT.
*> USING handle (in and out), enchantment id, level (1 or more): the enchantments component with the enchantment at that
*> level (replacing its level), the pairs in ascending id order; the new handle replaces the old one. At most 20 pairs
*> of the old component are read, so the new one fits SP-VALUE-MAX bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 13.
 01 WS-OLD                 PIC X(64).
 01 WS-NEW                 PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PAIRS.
    05 WS-PAIR OCCURS 40 TIMES.
       10 WS-ID            BINARY-LONG.
       10 WS-LEVEL         BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-ID L-LEVEL.
     MOVE 0 TO WS-N
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-OLD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-OLD WS-POS WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-POS > 63 OR WS-N >= 20
             ADD 1 TO WS-N
             CALL "SP-VARINT-GET" USING WS-OLD WS-POS WS-ID(WS-N)
             CALL "SP-VARINT-GET" USING WS-OLD WS-POS WS-LEVEL(WS-N)
         END-PERFORM
     END-IF
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF WS-ID(WS-I) = L-ID
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT = 0
         ADD 1 TO WS-N
         MOVE L-ID TO WS-ID(WS-N)
         MOVE WS-N TO WS-AT
     END-IF
     MOVE L-LEVEL TO WS-LEVEL(WS-AT)
*>   Ascending id order (a selection sort of at most 33 pairs).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-N
         PERFORM VARYING WS-J FROM WS-I BY 1 UNTIL WS-J > WS-N
             IF WS-ID(WS-J) < WS-ID(WS-I)
                 MOVE WS-PAIR(WS-I) TO WS-PAIR(40)
                 MOVE WS-PAIR(WS-J) TO WS-PAIR(WS-I)
                 MOVE WS-PAIR(40) TO WS-PAIR(WS-J)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE SPACES TO WS-NEW
     MOVE 1 TO WS-OUT
     CALL "SP-VARINT-PUT" USING WS-NEW WS-OUT WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "SP-VARINT-PUT" USING WS-NEW WS-OUT WS-ID(WS-I)
         CALL "SP-VARINT-PUT" USING WS-NEW WS-OUT WS-LEVEL(WS-I)
     END-PERFORM
     SUBTRACT 1 FROM WS-OUT
     CALL "SP-SET-COMPONENT" USING L-HANDLE WS-TYPE WS-NEW WS-OUT
     GOBACK.
 END PROGRAM SP-ADD-ENCHANT.
