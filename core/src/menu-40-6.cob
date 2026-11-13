*> Menus, part 6: the mount inventories of the horse family and the nautilus (docs/protocol/40-menus-6-mount-inventories.md sections 1 to 6; US12 phase 44).
*> Programs of plain numbers (MN6- prefix): each takes the facts the caller read (flags, counts, positions) and returns the decision or the pixel
*> arithmetic of the section. The live window of a player (menus.cob) is not changed by this file. Flags are 0 or 1. Entity numbers: 1 horse, 2 donkey,
*> 3 mule, 4 llama, 5 trader llama, 6 skeleton horse, 7 zombie horse, 8 nautilus, 9 zombie nautilus, 10 pig, 11 strider, 12 camel, 13 camel husk,
*> 14 happy ghast, 0 any other entity. Menu classes: 1 HorseInventoryMenu, 2 NautilusInventoryMenu. Slots: 0 saddle, 1 body. The generic click engine
*> and moveItemStackTo are 40-1; the entity physics and taming are other documents.
*>
*>   MN6-CLASS (1); MN6-SLOTS, -SLOT, -VALID, -CHANGED, -MAYPLACE, -MAYPICKUP, -ONEQUIP, -EQUIPSOUND, -EQUIPCONT, -ACTIVE, -ICON, -CANUSE, -EQUIPPABLE,
*>   -TAG, -ACCEPTS, -QUICK, -FINISH (2); MN6-OPENOK, -INTERACT, -OPENSTEPS, -PACKET, -CLIENT, -RESIZE (3); MN6-COLUMNS, -STRCLAMP, -LLAMA (4);
*>   MN6-VISIBLE (5); MN6-FRAME, -DRAWPLAN, -TEXTURE, -PIXELS, -ICONDRAW, -PREVIEW, -ANGLES, -PREVIEWBOX (6)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-CLASS.
*> USING entity, menu class out (0 none), menu type id out (-1: no registry entry), open packet id out (1 overview).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-CLASS L-TYPE L-PACKET.
    MOVE 0 TO L-CLASS
    MOVE -1 TO L-TYPE
    MOVE 42 TO L-PACKET
    EVALUATE TRUE
        WHEN L-ENTITY >= 1 AND L-ENTITY <= 7
            MOVE 1 TO L-CLASS
        WHEN L-ENTITY = 8 OR L-ENTITY = 9
            MOVE 2 TO L-CLASS
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-SLOTS.
*> USING chest columns, N out (2 + 3c), total slots out, main inventory start out, hotbar start out (2.1, 2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COLUMNS              BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-MAIN                 BINARY-LONG.
 01 L-HOTBAR               BINARY-LONG.
 PROCEDURE DIVISION USING L-COLUMNS L-N L-TOTAL L-MAIN L-HOTBAR.
    COMPUTE L-N = 2 + 3 * L-COLUMNS
    COMPUTE L-TOTAL = L-N + 36
    MOVE L-N TO L-MAIN
    COMPUTE L-HOTBAR = L-N + 27
    GOBACK.
 END PROGRAM MN6-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-SLOT.
*> USING menu slot, chest columns, x out, y out, part out (1 saddle, 2 body, 3 chest, 4 main inventory, 5 hotbar, 0 none) (2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-N                    BINARY-LONG.
 01 W-I                    BINARY-LONG.
 01 W-ROW                  BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-COLUMNS L-X L-Y L-PART.
    MOVE 0 TO L-X L-Y L-PART
    COMPUTE W-N = 2 + 3 * L-COLUMNS
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 8 TO L-X
            MOVE 18 TO L-Y
            MOVE 1 TO L-PART
        WHEN L-SLOT = 1
            MOVE 8 TO L-X
            MOVE 36 TO L-Y
            MOVE 2 TO L-PART
        WHEN L-SLOT < W-N
            COMPUTE W-I = L-SLOT - 2
            DIVIDE W-I BY L-COLUMNS GIVING W-ROW REMAINDER W-COL
            COMPUTE L-X = 80 + 18 * W-COL
            COMPUTE L-Y = 18 + 18 * W-ROW
            MOVE 3 TO L-PART
        WHEN L-SLOT < W-N + 27
            COMPUTE W-I = L-SLOT - W-N
            DIVIDE W-I BY 9 GIVING W-ROW REMAINDER W-COL
            COMPUTE L-X = 8 + 18 * W-COL
            COMPUTE L-Y = 84 + 18 * W-ROW
            MOVE 4 TO L-PART
        WHEN L-SLOT < W-N + 36
            COMPUTE L-X = 8 + 18 * (L-SLOT - W-N - 27)
            MOVE 142 TO L-Y
            MOVE 5 TO L-PART
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-VALID.
*> USING the entity container was replaced, container valid, mount alive, distance, valid out (2.1: tested in this order; range 4.0, inclusive).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-RANGE                FLOAT-LONG VALUE 4.0.
 01 W-GT                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHANGED              BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-DIST                 FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANGED L-VALID L-ALIVE L-DIST L-OK.
    MOVE 0 TO L-OK
    CALL "FCMP-GT" USING L-DIST W-RANGE W-GT
    IF L-CHANGED = 0 AND L-VALID = 1 AND L-ALIVE = 1 AND W-GT = 0
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN6-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-CHANGED.
*> USING the entity's container is the menu's container, hasInventoryChanged out (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-CHANGED.
    COMPUTE L-CHANGED = 1 - L-SAME
    GOBACK.
 END PROGRAM MN6-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-MAYPLACE.
*> USING stack has equippable, its slot is this slot, mount canUseSlot, allowed set absent, set contains the entity, ok out (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-ABSENT               BINARY-LONG.
 01 L-CONTAINS             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-SLOT L-CAN L-ABSENT L-CONTAINS L-OK.
    MOVE 0 TO L-OK
    IF L-HAS = 1 AND L-SLOT = 1 AND L-CAN = 1 AND (L-ABSENT = 1 OR L-CONTAINS = 1)
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN6-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-MAYPICKUP.
*> USING slot non-empty, player in creative mode, stack has prevent_armor_change, ok out (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NONEMPTY             BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-PREVENT              BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NONEMPTY L-CREATIVE L-PREVENT L-OK.
    MOVE 1 TO L-OK
    IF L-NONEMPTY = 1 AND L-CREATIVE = 0 AND L-PREVENT = 1
        MOVE 0 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN6-MAYPICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-ONEQUIP.
*> USING server side, spectator, same item and components, first tick, silent, new stack has equippable, its slot equals this slot, entity emits
*> equip events, sound out, game event out (0 none, 1 EQUIP, 2 UNEQUIP) (2.3 onEquipItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-SILENT               BINARY-LONG.
 01 L-HASEQ                BINARY-LONG.
 01 L-SLOTEQ               BINARY-LONG.
 01 L-EMITS                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-SPECTATOR L-SAME L-FIRST L-SILENT L-HASEQ L-SLOTEQ L-EMITS L-SOUND L-EVENT.
    MOVE 0 TO L-SOUND L-EVENT
    IF L-SERVER = 1 AND L-SPECTATOR = 0 AND L-SAME = 0 AND L-FIRST = 0
        IF L-SILENT = 0 AND L-HASEQ = 1 AND L-SLOTEQ = 1
            MOVE 1 TO L-SOUND
        END-IF
        IF L-EMITS = 1
            MOVE 2 TO L-EVENT
            IF L-HASEQ = 1
                MOVE 1 TO L-EVENT
            END-IF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN6-ONEQUIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-EQUIPSOUND.
*> USING menu class, saddle slot, under water, sound out (1 the item's own, 2 horse saddle, 3 nautilus underwater saddle, 4 nautilus saddle) (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-SADDLE               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-SADDLE L-WATER L-SOUND.
    MOVE 1 TO L-SOUND
    EVALUATE TRUE
        WHEN L-CLASS = 1 AND L-SADDLE = 1
            MOVE 2 TO L-SOUND
        WHEN L-CLASS = 2 AND L-SADDLE = 1 AND L-WATER = 1
            MOVE 3 TO L-SOUND
        WHEN L-CLASS = 2 AND L-SADDLE = 1
            MOVE 4 TO L-SOUND
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-EQUIPSOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-EQUIPCONT.
*> USING stack written is non-empty, player rides the mob, distance, guaranteed drop and persistence out, stillValid out (2.2 equipment container).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-RANGE                FLOAT-LONG VALUE 4.0.
 01 W-GT                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NONEMPTY             BINARY-LONG.
 01 L-RIDING               BINARY-LONG.
 01 L-DIST                 FLOAT-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-NONEMPTY L-RIDING L-DIST L-DROP L-VALID.
    MOVE L-NONEMPTY TO L-DROP
    MOVE 0 TO L-VALID
    CALL "FCMP-GT" USING L-DIST W-RANGE W-GT
    IF L-RIDING = 1 OR W-GT = 0
        MOVE 1 TO L-VALID
    END-IF
    GOBACK.
 END PROGRAM MN6-EQUIPCONT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-ACTIVE.
*> USING menu class, slot (0 saddle, 1 body), canUseSlot, in tag can_equip_saddle, in tag can_wear_horse_armor, is a llama, active out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-TAGSADDLE            BINARY-LONG.
 01 L-TAGARMOR             BINARY-LONG.
 01 L-LLAMA                BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-SLOT L-CAN L-TAGSADDLE L-TAGARMOR L-LLAMA L-ACTIVE.
    MOVE L-CAN TO L-ACTIVE
    EVALUATE TRUE
        WHEN L-CLASS = 1 AND L-SLOT = 0
            IF L-TAGSADDLE = 0
                MOVE 0 TO L-ACTIVE
            END-IF
        WHEN L-CLASS = 1
            IF L-TAGARMOR = 0 AND L-LLAMA = 0
                MOVE 0 TO L-ACTIVE
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-ACTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-ICON.
*> USING menu class, slot, llama, empty-slot icon name out, icon size out (2.4, 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-LLAMA                BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-SIZE                 PIC X(96).
 PROCEDURE DIVISION USING L-CLASS L-SLOT L-LLAMA L-NAME L-SIZE.
    MOVE SPACES TO L-NAME L-SIZE
    MOVE "16x16" TO L-SIZE
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE "container/slot/saddle" TO L-NAME
        WHEN L-CLASS = 1 AND L-LLAMA = 1
            MOVE "container/slot/llama_armor" TO L-NAME
        WHEN L-CLASS = 1
            MOVE "container/slot/horse_armor" TO L-NAME
        WHEN OTHER
            MOVE "container/slot/nautilus_armor_inventory" TO L-NAME
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-ICON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-CANUSE.
*> USING entity, slot (0 saddle, 1 body), alive, baby, tamed, canUseSlot out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-TAMED                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-SLOT L-ALIVE L-BABY L-TAMED L-CAN.
    MOVE 0 TO L-CAN
    EVALUATE TRUE
        WHEN L-ENTITY = 4 OR L-ENTITY = 5
            MOVE 1 TO L-CAN
        WHEN (L-ENTITY >= 1 AND L-ENTITY <= 3 OR L-ENTITY = 6 OR L-ENTITY = 7) AND L-SLOT = 1
            MOVE 1 TO L-CAN
        WHEN L-ENTITY >= 1 AND L-ENTITY <= 9 AND L-ALIVE = 1 AND L-BABY = 0 AND L-TAMED = 1
            MOVE 1 TO L-CAN
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-CANUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-EQUIPPABLE.
*> USING item kind (1 saddle, 2 llama carpet, 3 horse armor, 4 nautilus armor), slot out (0 saddle, 1 body), can be sheared out, stack size out (2.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-SHEAR                BINARY-LONG.
 01 L-STACK                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SLOT L-SHEAR L-STACK.
    MOVE 1 TO L-SLOT L-SHEAR L-STACK
    IF L-KIND = 1
        MOVE 0 TO L-SLOT
    END-IF
    GOBACK.
 END PROGRAM MN6-EQUIPPABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-TAG.
*> USING tag (1 can_equip_saddle, 2 can_wear_horse_armor, 3 can_wear_nautilus_armor, 4 can_equip_harness), entity, member out (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-ENTITY L-MEMBER.
    MOVE 0 TO L-MEMBER
    EVALUATE TRUE
        WHEN L-TAG = 1 AND ((L-ENTITY >= 1 AND L-ENTITY <= 3) OR (L-ENTITY >= 6 AND L-ENTITY <= 13))
            MOVE 1 TO L-MEMBER
        WHEN L-TAG = 2 AND (L-ENTITY = 1 OR L-ENTITY = 7)
            MOVE 1 TO L-MEMBER
        WHEN L-TAG = 3 AND (L-ENTITY = 8 OR L-ENTITY = 9)
            MOVE 1 TO L-MEMBER
        WHEN L-TAG = 4 AND L-ENTITY = 14
            MOVE 1 TO L-MEMBER
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-ACCEPTS.
*> USING item kind (1 saddle, 2 llama carpet, 3 horse armor, 4 nautilus armor), entity, accepted out (2.5: the item's allowed-entities set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-TAG                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ENTITY L-OK.
    MOVE 0 TO L-OK
    EVALUATE L-KIND
        WHEN 2
            IF L-ENTITY = 4 OR L-ENTITY = 5
                MOVE 1 TO L-OK
            END-IF
        WHEN 1
            MOVE 1 TO W-TAG
            CALL "MN6-TAG" USING W-TAG L-ENTITY L-OK
        WHEN 3
            MOVE 2 TO W-TAG
            CALL "MN6-TAG" USING W-TAG L-ENTITY L-OK
        WHEN OTHER
            MOVE 3 TO W-TAG
            CALL "MN6-TAG" USING W-TAG L-ENTITY L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-ACCEPTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-QUICK.
*> USING source index, chest columns, body slot accepts and is empty, saddle slot accepts and is empty, the attempted move moved something, the chest move
*> moved something, rule out (1 mount part to inventory in reverse, 2 body, 3 saddle, 4 chest, 5 hotbar to main, 6 main to hotbar, 7 none), range start out,
*> range end out (exclusive), reverse out, original copy returned out (2.6; the shuffle rules return the empty stack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-N                    BINARY-LONG.
 01 W-TOTAL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-BODY                 BINARY-LONG.
 01 L-SADDLE               BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-RETURN               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-COLUMNS L-BODY L-SADDLE L-MOVED L-CHEST L-RULE L-START L-END L-REVERSE L-RETURN.
    MOVE 0 TO L-REVERSE L-RETURN
    COMPUTE W-N = 2 + 3 * L-COLUMNS
    COMPUTE W-TOTAL = W-N + 36
    EVALUATE TRUE
        WHEN L-INDEX < W-N
            MOVE 1 TO L-RULE L-REVERSE
            MOVE W-N TO L-START
            MOVE W-TOTAL TO L-END
            MOVE L-MOVED TO L-RETURN
        WHEN L-BODY = 1
            MOVE 2 TO L-RULE
            MOVE 1 TO L-START
            MOVE 2 TO L-END
            MOVE L-MOVED TO L-RETURN
        WHEN L-SADDLE = 1
            MOVE 3 TO L-RULE
            MOVE 0 TO L-START
            MOVE 1 TO L-END
            MOVE L-MOVED TO L-RETURN
        WHEN L-COLUMNS > 0 AND L-CHEST = 1
            MOVE 4 TO L-RULE
            MOVE 2 TO L-START
            MOVE W-N TO L-END
            MOVE 1 TO L-RETURN
        WHEN L-INDEX >= W-N + 27 AND L-INDEX < W-TOTAL
            MOVE 5 TO L-RULE
            MOVE W-N TO L-START
            COMPUTE L-END = W-N + 27
        WHEN L-INDEX >= W-N AND L-INDEX < W-N + 27
            MOVE 6 TO L-RULE
            COMPUTE L-START = W-N + 27
            MOVE W-TOTAL TO L-END
        WHEN OTHER
            MOVE 7 TO L-RULE
            COMPUTE L-START = W-N + 27
            MOVE L-START TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-FINISH.
*> USING the source stack is now empty, action out (1 set the slot empty as a player change, 2 setChanged) (2.6 finish step).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-ACTION.
    MOVE 2 TO L-ACTION
    IF L-EMPTY = 1
        MOVE 1 TO L-ACTION
    END-IF
    GOBACK.
 END PROGRAM MN6-FINISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-OPENOK.
*> USING the mount has no passengers, the player is a passenger of it, the mount is tamed, opens out (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOPASS               BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-TAMED                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NOPASS L-PASSENGER L-TAMED L-OK.
    MOVE 0 TO L-OK
    IF (L-NOPASS = 1 OR L-PASSENGER = 1) AND L-TAMED = 1
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN6-OPENOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-INTERACT.
*> USING kind (1 horse, 2 nautilus), baby, is a vehicle, tamed, secondary use, result out (0 superclass, 1 open the screen and succeed, 2 held-item handling) (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-VEHICLE              BINARY-LONG.
 01 L-TAMED                BINARY-LONG.
 01 L-SECONDARY            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-BABY L-VEHICLE L-TAMED L-SECONDARY L-RESULT.
    EVALUATE TRUE
        WHEN L-BABY = 1
            MOVE 0 TO L-RESULT
        WHEN L-KIND = 1 AND L-VEHICLE = 1
            MOVE 0 TO L-RESULT
        WHEN L-TAMED = 1 AND L-SECONDARY = 1
            MOVE 1 TO L-RESULT
        WHEN OTHER
            MOVE 2 TO L-RESULT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-OPENSTEPS.
*> USING the player's menu is the inventory menu, container counter, close the current menu first out, new counter out (1 to 100) (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INVENTORY            BINARY-LONG.
 01 L-COUNTER              BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INVENTORY L-COUNTER L-CLOSE L-NEW.
    COMPUTE L-CLOSE = 1 - L-INVENTORY
    COMPUTE L-NEW = FUNCTION MOD(L-COUNTER, 100) + 1
    GOBACK.
 END PROGRAM MN6-OPENSTEPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-HEXBYTE.
*> USING byte 0 to 255, text, position: appends the byte as two lower-case hex digits at the position and advances it (3.2 helper).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-DIGITS               PIC X(16) VALUE "0123456789abcdef".
 01 W-HI                   BINARY-LONG.
 01 W-LO                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BYTE                 BINARY-LONG.
 01 L-TEXT                 PIC X(96).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BYTE L-TEXT L-POS.
    DIVIDE L-BYTE BY 16 GIVING W-HI REMAINDER W-LO
    ADD 1 TO W-HI W-LO
    MOVE W-DIGITS(W-HI:1) TO L-TEXT(L-POS:1)
    ADD 1 TO L-POS
    MOVE W-DIGITS(W-LO:1) TO L-TEXT(L-POS:1)
    ADD 1 TO L-POS
    GOBACK.
 END PROGRAM MN6-HEXBYTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-VARINT.
*> USING value, text, position: appends the VarInt bytes of a non-negative value as hex (3.2 helper).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-V                    BINARY-LONG.
 01 W-BYTE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-TEXT                 PIC X(96).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TEXT L-POS.
    MOVE L-VALUE TO W-V
    PERFORM WITH TEST AFTER UNTIL W-V = 0
        DIVIDE W-V BY 128 GIVING W-V REMAINDER W-BYTE
        IF W-V > 0
            ADD 128 TO W-BYTE
        END-IF
        CALL "MN6-HEXBYTE" USING W-BYTE L-TEXT L-POS
    END-PERFORM
    GOBACK.
 END PROGRAM MN6-VARINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-PACKET.
*> USING container id, inventory columns, entity id, bytes as hex out, byte count out as text (3.2: VarInt, VarInt, 4-byte big-endian Int).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 01 W-U                    BINARY-DOUBLE.
 01 W-B                    BINARY-LONG.
 01 W-LEN                  BINARY-LONG.
 01 W-ED                   PIC Z9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HEX                  PIC X(96).
 01 L-COUNT                PIC X(96).
 PROCEDURE DIVISION USING L-ID L-COLUMNS L-ENTITY L-HEX L-COUNT.
    MOVE SPACES TO L-HEX L-COUNT
    MOVE 1 TO W-POS
    CALL "MN6-VARINT" USING L-ID L-HEX W-POS
    CALL "MN6-VARINT" USING L-COLUMNS L-HEX W-POS
    MOVE L-ENTITY TO W-U
    IF W-U < 0
        ADD 4294967296 TO W-U
    END-IF
    DIVIDE W-U BY 16777216 GIVING W-B REMAINDER W-U
    CALL "MN6-HEXBYTE" USING W-B L-HEX W-POS
    DIVIDE W-U BY 65536 GIVING W-B REMAINDER W-U
    CALL "MN6-HEXBYTE" USING W-B L-HEX W-POS
    DIVIDE W-U BY 256 GIVING W-B REMAINDER W-U
    CALL "MN6-HEXBYTE" USING W-B L-HEX W-POS
    MOVE W-U TO W-B
    CALL "MN6-HEXBYTE" USING W-B L-HEX W-POS
    COMPUTE W-LEN = (W-POS - 1) / 2
    MOVE W-LEN TO W-ED
    MOVE W-ED TO L-COUNT
    GOBACK.
 END PROGRAM MN6-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-CLIENT.
*> USING entity found, entity, columns, menu class out (0 none), menu installed out, chest container size out (3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-TYPE                 BINARY-LONG.
 01 W-PACKET               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FOUND                BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-INSTALLED            BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FOUND L-ENTITY L-COLUMNS L-CLASS L-INSTALLED L-SIZE.
    MOVE 0 TO L-CLASS L-INSTALLED L-SIZE
    IF L-FOUND = 1
        CALL "MN6-CLASS" USING L-ENTITY L-CLASS W-TYPE W-PACKET
        IF L-CLASS > 0
            MOVE 1 TO L-INSTALLED
            COMPUTE L-SIZE = L-COLUMNS * 3
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN6-CLIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-RESIZE.
*> USING old size, new size, stacks copied out, stacks lost out (3.4 createInventory copies min(old, new) slots).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-COPIED               BINARY-LONG.
 01 L-LOST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-NEW L-COPIED L-LOST.
    MOVE L-OLD TO L-COPIED
    MOVE 0 TO L-LOST
    IF L-NEW < L-OLD
        MOVE L-NEW TO L-COPIED
        COMPUTE L-LOST = L-OLD - L-NEW
    END-IF
    GOBACK.
 END PROGRAM MN6-RESIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-COLUMNS.
*> USING entity, chest flag, llama strength, columns out, chest slots out (4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-SLOTS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-CHEST L-STRENGTH L-COLUMNS L-SLOTS.
    MOVE 0 TO L-COLUMNS L-SLOTS
    EVALUATE TRUE
        WHEN (L-ENTITY = 2 OR L-ENTITY = 3) AND L-CHEST = 1
            MOVE 5 TO L-COLUMNS
        WHEN (L-ENTITY = 4 OR L-ENTITY = 5) AND L-CHEST = 1
            MOVE L-STRENGTH TO L-COLUMNS
    END-EVALUATE
    COMPUTE L-SLOTS = 3 * L-COLUMNS
    GOBACK.
 END PROGRAM MN6-COLUMNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-STRCLAMP.
*> USING value, strength out (4: setStrength clamps into 1 to 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-STRENGTH.
    MOVE L-VALUE TO L-STRENGTH
    IF L-STRENGTH < 1
        MOVE 1 TO L-STRENGTH
    END-IF
    IF L-STRENGTH > 5
        MOVE 5 TO L-STRENGTH
    END-IF
    GOBACK.
 END PROGRAM MN6-STRCLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-LLAMA.
*> USING the nextFloat draw, the nextInt(bound) result, bound out, strength out (4: below the single precision 0.04 the bound is 5, else 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-F32                  FLOAT-SHORT.
 01 W-T32                  FLOAT-SHORT.
 01 W-F64                  FLOAT-LONG.
 01 W-T64                  FLOAT-LONG.
 01 W-GT                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-ROLL L-BOUND L-STRENGTH.
    MOVE L-DRAW TO W-F32
    MOVE 0.04 TO W-T32
    MOVE W-F32 TO W-F64
    MOVE W-T32 TO W-T64
    CALL "FCMP-GT" USING W-T64 W-F64 W-GT
    MOVE 3 TO L-BOUND
    IF W-GT = 1
        MOVE 5 TO L-BOUND
    END-IF
    COMPUTE L-STRENGTH = 1 + L-ROLL
    GOBACK.
 END PROGRAM MN6-LLAMA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-VISIBLE.
*> USING entity, tamed, baby, chest flag, llama strength, saddle slot shown out, body slot shown out, chest columns out, body icon out (0 none, 1 llama
*> armor, 2 horse armor, 3 nautilus armor) (5.2, composed from the activity, tag and column rules).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CLASS                BINARY-LONG.
 01 W-TYPE                 BINARY-LONG.
 01 W-PACKET               BINARY-LONG.
 01 W-SADDLE               BINARY-LONG VALUE 0.
 01 W-BODY                 BINARY-LONG VALUE 1.
 01 W-ALIVE                BINARY-LONG VALUE 1.
 01 W-TAG1                 BINARY-LONG VALUE 1.
 01 W-TAG2                 BINARY-LONG VALUE 2.
 01 W-CAN0                 BINARY-LONG.
 01 W-CAN1                 BINARY-LONG.
 01 W-IN1                  BINARY-LONG.
 01 W-IN2                  BINARY-LONG.
 01 W-LLAMA                BINARY-LONG.
 01 W-SLOTS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-TAMED                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-SADDLE               BINARY-LONG.
 01 L-BODYSHOWN            BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-ICON                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-TAMED L-BABY L-CHEST L-STRENGTH L-SADDLE L-BODYSHOWN L-COLUMNS L-ICON.
    CALL "MN6-CLASS" USING L-ENTITY W-CLASS W-TYPE W-PACKET
    MOVE 0 TO W-LLAMA L-ICON
    IF L-ENTITY = 4 OR L-ENTITY = 5
        MOVE 1 TO W-LLAMA
    END-IF
    CALL "MN6-CANUSE" USING L-ENTITY W-SADDLE W-ALIVE L-BABY L-TAMED W-CAN0
    CALL "MN6-CANUSE" USING L-ENTITY W-BODY W-ALIVE L-BABY L-TAMED W-CAN1
    CALL "MN6-TAG" USING W-TAG1 L-ENTITY W-IN1
    CALL "MN6-TAG" USING W-TAG2 L-ENTITY W-IN2
    CALL "MN6-ACTIVE" USING W-CLASS W-SADDLE W-CAN0 W-IN1 W-IN2 W-LLAMA L-SADDLE
    CALL "MN6-ACTIVE" USING W-CLASS W-BODY W-CAN1 W-IN1 W-IN2 W-LLAMA L-BODYSHOWN
    CALL "MN6-COLUMNS" USING L-ENTITY L-CHEST L-STRENGTH L-COLUMNS W-SLOTS
    EVALUATE TRUE
        WHEN L-BODYSHOWN = 1 AND W-LLAMA = 1
            MOVE 1 TO L-ICON
        WHEN L-BODYSHOWN = 1 AND W-CLASS = 1
            MOVE 2 TO L-ICON
        WHEN L-BODYSHOWN = 1
            MOVE 3 TO L-ICON
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-VISIBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-FRAME.
*> USING window width, window height, leftPos out, topPos out, title x out, title y out, inventory label x out, inventory label y out (6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WIDTH L-HEIGHT L-LEFT L-TOP L-TX L-TY L-IX L-IY.
    COMPUTE L-LEFT = (L-WIDTH - 176) / 2
    COMPUTE L-TOP = (L-HEIGHT - 166) / 2
    MOVE 8 TO L-TX L-IX
    MOVE 6 TO L-TY
    MOVE 72 TO L-IY
    GOBACK.
 END PROGRAM MN6-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-DRAWPLAN.
*> USING screen class (1 horse, 2 nautilus), columns, saddle slot active, body slot active, chest area drawn out, its width out, saddle frame out,
*> body frame out (6.2: the chest sprite at (79, 17) only for the horse screen with columns > 0; frames at (7, 17) and (7, 35)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 01 L-SADDLE               BINARY-LONG.
 01 L-BODY                 BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-SFRAME               BINARY-LONG.
 01 L-BFRAME               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-COLUMNS L-SADDLE L-BODY L-CHEST L-WIDTH L-SFRAME L-BFRAME.
    MOVE 0 TO L-CHEST L-WIDTH
    IF L-COLUMNS > 0 AND L-CLASS = 1
        MOVE 1 TO L-CHEST
        COMPUTE L-WIDTH = L-COLUMNS * 18
    END-IF
    MOVE L-SADDLE TO L-SFRAME
    MOVE L-BODY TO L-BFRAME
    GOBACK.
 END PROGRAM MN6-DRAWPLAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-TEXTURE.
*> USING item (1 horse background, 2 nautilus background, 3 chest slots sprite, 4 slot frame sprite), name out, size out (6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-SIZE                 PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-NAME L-SIZE.
    MOVE SPACES TO L-NAME L-SIZE
    EVALUATE L-KIND
        WHEN 1
            MOVE "textures/gui/container/horse.png" TO L-NAME
            MOVE "176x166 of 256x256" TO L-SIZE
        WHEN 2
            MOVE "textures/gui/container/nautilus.png" TO L-NAME
            MOVE "176x166 of 256x256" TO L-SIZE
        WHEN 3
            MOVE "container/horse/chest_slots" TO L-NAME
            MOVE "90x54" TO L-SIZE
        WHEN 4
            MOVE "container/slot" TO L-NAME
            MOVE "18x18" TO L-SIZE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-PIXELS.
*> USING element (1 background, 2 saddle frame, 3 body frame, 4 saddle item, 5 body item, 6 chest area for 3 columns, 7 chest slot (0, 0) item, 8 entity
*> preview box, 9 main inventory, 10 hotbar), x out, y out, width out, height out (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ELEMENT              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ELEMENT L-X L-Y L-W L-H.
    EVALUATE L-ELEMENT
        WHEN 1
            MOVE 0 TO L-X L-Y
            MOVE 176 TO L-W
            MOVE 166 TO L-H
        WHEN 2
            MOVE 7 TO L-X
            MOVE 17 TO L-Y
            MOVE 18 TO L-W L-H
        WHEN 3
            MOVE 7 TO L-X
            MOVE 35 TO L-Y
            MOVE 18 TO L-W L-H
        WHEN 4
            MOVE 8 TO L-X
            MOVE 18 TO L-Y
            MOVE 16 TO L-W L-H
        WHEN 5
            MOVE 8 TO L-X
            MOVE 36 TO L-Y
            MOVE 16 TO L-W L-H
        WHEN 6
            MOVE 79 TO L-X
            MOVE 17 TO L-Y
            MOVE 54 TO L-W L-H
        WHEN 7
            MOVE 80 TO L-X
            MOVE 18 TO L-Y
            MOVE 16 TO L-W L-H
        WHEN 8
            MOVE 26 TO L-X
            MOVE 18 TO L-Y
            MOVE 52 TO L-W L-H
        WHEN 9
            MOVE 8 TO L-X
            MOVE 84 TO L-Y
            MOVE 162 TO L-W
            MOVE 54 TO L-H
        WHEN OTHER
            MOVE 8 TO L-X
            MOVE 142 TO L-Y
            MOVE 162 TO L-W
            MOVE 18 TO L-H
    END-EVALUATE
    GOBACK.
 END PROGRAM MN6-PIXELS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-ICONDRAW.
*> USING slot active, item empty, icon drawn out, slot drawn out (6.2: inactive slots are skipped entirely).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-ICON                 BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-EMPTY L-ICON L-DRAWN.
    MOVE L-ACTIVE TO L-DRAWN
    MOVE 0 TO L-ICON
    IF L-ACTIVE = 1 AND L-EMPTY = 1
        MOVE 1 TO L-ICON
    END-IF
    GOBACK.
 END PROGRAM MN6-ICONDRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-PREVIEW.
*> USING leftPos, topPos, x0 out, y0 out, x1 out, y1 out, centre x out, centre y out, scale out, y offset out (x 1e6) (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-TOP L-X0 L-Y0 L-X1 L-Y1 L-CX L-CY L-SCALE L-OFFSET.
    COMPUTE L-X0 = L-LEFT + 26
    COMPUTE L-Y0 = L-TOP + 18
    COMPUTE L-X1 = L-LEFT + 78
    COMPUTE L-Y1 = L-TOP + 70
    COMPUTE L-CX = (L-X0 + L-X1) / 2
    COMPUTE L-CY = (L-Y0 + L-Y1) / 2
    MOVE 17 TO L-SCALE
    MOVE 250000 TO L-OFFSET
    GOBACK.
 END PROGRAM MN6-PREVIEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-ANGLES.
*> USING centre x, centre y, mouse x, mouse y (float), fall flying, ax out, ay out, body rotation out, head yaw out, head pitch out, X rotation (radians)
*> out, all x 1e6 (6.4: ax = atan((cx - mouseX) / 40), the products ax x 20 and ay x 20 are taken as degrees as the document gives them).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ARG                  FLOAT-LONG.
 01 W-AX                   FLOAT-LONG.
 01 W-AY                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-MX                   FLOAT-LONG.
 01 L-MY                   FLOAT-LONG.
 01 L-FALL                 BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-BODY                 BINARY-LONG.
 01 L-YAW                  BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 01 L-QX                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CY L-MX L-MY L-FALL L-AX L-AY L-BODY L-YAW L-PITCH L-QX.
    COMPUTE W-ARG = (L-CX - L-MX) / 40.0
    COMPUTE W-AX = FUNCTION ATAN(W-ARG)
    COMPUTE W-ARG = (L-CY - L-MY) / 40.0
    COMPUTE W-AY = FUNCTION ATAN(W-ARG)
    COMPUTE L-AX ROUNDED = W-AX * 1000000
    COMPUTE L-AY ROUNDED = W-AY * 1000000
    COMPUTE L-BODY ROUNDED = (180 + W-AX * 20) * 1000000
    COMPUTE L-YAW ROUNDED = W-AX * 20 * 1000000
    MOVE 0 TO L-PITCH
    IF L-FALL = 0
        COMPUTE L-PITCH ROUNDED = 0 - W-AY * 20 * 1000000
    END-IF
    COMPUTE L-QX ROUNDED = W-AY * 20 * 0.017453292 * 1000000
    GOBACK.
 END PROGRAM MN6-ANGLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN6-PREVIEWBOX.
*> USING bounding box width, height, state scale (floats), width out, height out, translation y out, all x 1e6 (6.4 steps 4 and 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-OW                   BINARY-LONG.
 01 L-OH                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-SCALE L-OW L-OH L-TY.
    COMPUTE L-OW ROUNDED = L-W / L-SCALE * 1000000
    COMPUTE L-OH ROUNDED = L-H / L-SCALE * 1000000
    COMPUTE L-TY ROUNDED = (L-H / L-SCALE / 2 + 0.25) * 1000000
    GOBACK.
 END PROGRAM MN6-PREVIEWBOX.
