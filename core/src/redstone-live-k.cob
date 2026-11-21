*> Live redstone, block sounds and the hopper's item transfer.
*> Sounds (30-redstone-7 section 1 rule 2 and 4.2 to 5.3, 30-5 4 and 7.4): a Sound Effect (05b 0x77, as the chest and the note block send theirs) from the block centre to the viewers of the chunk, source
*> BLOCKS: doors, trapdoors and fence gates (volume 1.0, pitch nextFloat x 0.1 + 0.9; the sound family of the wood or metal of the block), the copper bulb, pressure plates (1.0, 1.0) and the tripwire hook
*> (volume 0.4 and the pitches of 7.4). The excluded actor of a hand toggle (the sound the actor's own client predicts) is not excluded here: every viewer hears it.
*> Hopper (31-redstone-2 section 5): HOPPER-TICK-ALL runs every hopper block entity's pushItemsTick: the cooldown, the push of one item into the container in front (the first slot the target accepts), the
*> pull of one item from the container above, `enabled`, the cooldown 8 after a move and for a hopper that received into an empty hopper (8 or 7 by the tick order). Containers are the block entity containers
*> without face rules (chests, barrels, shulker boxes, dispensers, droppers, hoppers): a furnace, brewing stand or crafter (slots by face), a double chest as one container, item entities above the hopper,
*> and hopper minecarts are not handled.
*> Entry points:
*>   RL-BLOCK-SOUND USING dim, x, y, z, block key (PIC X(48), bare), event: 1 open, 2 close (door, trapdoor, fence gate), 3 bulb on, 4 bulb off, 5 plate on, 6 plate off, 7 hook on, 8 hook off, 9 hook attach, 10 hook detach
*>   HOPPER-TICK-ALL                                                         called by CORE-TICK

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-BLOCK-SOUND-NAME.
*> USING block key, event, sound key out (PIC X(48), without minecraft:), volume out and pitch out (millionths): what RL-BLOCK-SOUND plays.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SALT                BINARY-LONG VALUE 9302.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-NAME                PIC X(48).
 01 WS-STEM                PIC X(48).
 01 WS-FAMILY              PIC X(24).
 01 WS-SIDE                PIC X(12).
 01 WS-LEN                 BINARY-LONG.
 01 WS-STEM-LEN            BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-NAME40              PIC X(40).
 01 WS-SET                 BINARY-LONG.
 01 WS-SENS                BINARY-LONG.
 01 WS-FAM                 BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-EVENT                BINARY-LONG.
 01 L-OUT                  PIC X(48).
 01 L-VOLUME               BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-EVENT L-OUT L-VOLUME L-PITCH.
     MOVE 1000000 TO L-VOLUME
     MOVE 1000000 TO L-PITCH
     MOVE SPACES TO WS-NAME L-OUT
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
     MOVE "open" TO WS-SIDE
     IF L-EVENT = 2 OR L-EVENT = 4 OR L-EVENT = 6
         MOVE "close" TO WS-SIDE
     END-IF
     EVALUATE TRUE
         WHEN L-EVENT = 1 OR L-EVENT = 2
*>           the block's sound family from the stem of its key (the BlockSetType and WoodType tables of 30-7 section 2)
             MOVE SPACES TO WS-STEM
             EVALUATE TRUE
                 WHEN WS-LEN >= 11 AND L-KEY(WS-LEN - 10:11) = "_fence_gate"
                     COMPUTE WS-STEM-LEN = WS-LEN - 11
                     MOVE "fence_gate" TO WS-NAME
                 WHEN WS-LEN >= 9 AND L-KEY(WS-LEN - 8:9) = "_trapdoor"
                     COMPUTE WS-STEM-LEN = WS-LEN - 9
                     MOVE "trapdoor" TO WS-NAME
                 WHEN OTHER
                     COMPUTE WS-STEM-LEN = WS-LEN - 5
                     MOVE "door" TO WS-NAME
             END-EVALUATE
             MOVE L-KEY(1:WS-STEM-LEN) TO WS-STEM
             MOVE 0 TO WS-HITS
             INSPECT WS-STEM TALLYING WS-HITS FOR ALL "copper"
             EVALUATE TRUE
                 WHEN WS-NAME = "fence_gate"
                     EVALUATE TRUE
                         WHEN WS-STEM = "cherry"
                             MOVE "cherry_wood_" TO WS-FAMILY
                         WHEN WS-STEM = "crimson" OR WS-STEM = "warped"
                             MOVE "nether_wood_" TO WS-FAMILY
                         WHEN WS-STEM = "bamboo"
                             MOVE "bamboo_wood_" TO WS-FAMILY
                         WHEN OTHER
                             MOVE SPACES TO WS-FAMILY
                     END-EVALUATE
                 WHEN WS-STEM = "iron"
                     MOVE "iron_" TO WS-FAMILY
                 WHEN WS-HITS > 0
                     MOVE "copper_" TO WS-FAMILY
                 WHEN WS-STEM = "cherry"
                     MOVE "cherry_wood_" TO WS-FAMILY
                 WHEN WS-STEM = "crimson" OR WS-STEM = "warped"
                     MOVE "nether_wood_" TO WS-FAMILY
                 WHEN WS-STEM = "bamboo"
                     MOVE "bamboo_wood_" TO WS-FAMILY
                 WHEN OTHER
                     MOVE "wooden_" TO WS-FAMILY
             END-EVALUATE
             MOVE SPACES TO L-OUT
             STRING "block." FUNCTION TRIM(WS-FAMILY) FUNCTION TRIM(WS-NAME) "." FUNCTION TRIM(WS-SIDE)
                 DELIMITED BY SIZE INTO L-OUT
             COMPUTE L-PITCH = WS-DRAW / 10 + 900000
         WHEN L-EVENT = 3
             MOVE "block.copper_bulb.turn_on" TO L-OUT
         WHEN L-EVENT = 4
             MOVE "block.copper_bulb.turn_off" TO L-OUT
         WHEN L-EVENT = 5 OR L-EVENT = 6
             MOVE L-KEY TO WS-NAME40
             MOVE "metal" TO WS-FAMILY
             IF NOT (WS-LEN >= 14 AND (L-KEY(1:14) = "light_weighted" OR L-KEY(1:14) = "heavy_weighted"))
                 CALL "RS2-PLATE-INFO" USING WS-NAME40 WS-SET WS-SENS WS-FAM WS-TIME
                 EVALUATE WS-FAM
                     WHEN 2
                         MOVE "wooden" TO WS-FAMILY
                     WHEN 3
                         MOVE "cherry_wood" TO WS-FAMILY
                     WHEN 4
                         MOVE "nether_wood" TO WS-FAMILY
                     WHEN 5
                         MOVE "bamboo_wood" TO WS-FAMILY
                     WHEN OTHER
                         MOVE "stone" TO WS-FAMILY
                 END-EVALUATE
             END-IF
             MOVE SPACES TO L-OUT
             IF L-EVENT = 5
                 STRING "block." FUNCTION TRIM(WS-FAMILY) "_pressure_plate.click_on" DELIMITED BY SIZE INTO L-OUT
             ELSE
                 STRING "block." FUNCTION TRIM(WS-FAMILY) "_pressure_plate.click_off" DELIMITED BY SIZE INTO L-OUT
             END-IF
         WHEN L-EVENT = 7
             MOVE "block.tripwire.click_on" TO L-OUT
             MOVE 400000 TO L-VOLUME
             MOVE 600000 TO L-PITCH
         WHEN L-EVENT = 8
             MOVE "block.tripwire.click_off" TO L-OUT
             MOVE 400000 TO L-VOLUME
             MOVE 500000 TO L-PITCH
         WHEN L-EVENT = 9
             MOVE "block.tripwire.attach" TO L-OUT
             MOVE 400000 TO L-VOLUME
             MOVE 700000 TO L-PITCH
         WHEN OTHER
             MOVE "block.tripwire.detach" TO L-OUT
             MOVE 400000 TO L-VOLUME
*>           1.2 / (nextFloat x 0.2 + 0.9)
             COMPUTE L-PITCH = 1200000 / (WS-DRAW / 5000000 + 0.9)
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-BLOCK-SOUND-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-BLOCK-SOUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BLOCKS              BINARY-LONG VALUE 4.
 01 WS-OUT                 PIC X(48).
 01 WS-VOLUME              BINARY-LONG.
 01 WS-PITCH               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY L-EVENT.
     CALL "RL-BLOCK-SOUND-NAME" USING L-KEY L-EVENT WS-OUT WS-VOLUME WS-PITCH
     CALL "RL-SOUND-AT" USING L-DIM L-X L-Y L-Z WS-OUT WS-BLOCKS WS-VOLUME WS-PITCH
     GOBACK.
 END PROGRAM RL-BLOCK-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-WORLDLY.
*> USING block entity type, kind out: 1 for a furnace, smoker or blast furnace, 2 for a brewing stand (the containers with slots by face, 31-2 3.1 and 4.1), 0 for the others (their slots are the flat list 0 to size - 1, 5.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KIND.
     MOVE 0 TO L-KIND
     EVALUATE L-TYPE
         WHEN 0 WHEN 27 WHEN 28
             MOVE 1 TO L-KIND
         WHEN 12
             MOVE 2 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM HOPPER-WORLDLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-FACE-SLOT.
*> USING block entity index, face (0 down, 1 up, 2 side), n, slot out: the n-th slot (1 based) of getSlots(container, face) (31-2 5.4), 0 past the end. A furnace gives down [result, fuel], up [input],
*> a side [fuel]; a brewing stand up [reagent], down [potions, reagent], a side [potions, fuel]; any other container the flat list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-LIST-SLOT        BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-FACE L-N L-SLOT.
     MOVE 0 TO L-SLOT
     CALL "HOPPER-WORLDLY" USING BE-TYPE(L-INDEX) WS-KIND
     CALL "BE-CONTAINER-SIZE" USING BE-TYPE(L-INDEX) WS-SIZE
     EVALUATE WS-KIND
         WHEN 1
             EVALUATE TRUE
                 WHEN L-FACE = 0 AND L-N = 1
                     MOVE 3 TO L-SLOT
                 WHEN L-FACE = 0 AND L-N = 2
                     MOVE 2 TO L-SLOT
                 WHEN L-FACE = 1 AND L-N = 1
                     MOVE 1 TO L-SLOT
                 WHEN L-FACE = 2 AND L-N = 1
                     MOVE 2 TO L-SLOT
             END-EVALUATE
         WHEN 2
             CALL "BE2-BREW-FACE" USING L-FACE WS-LIST WS-COUNT
             IF L-N <= WS-COUNT
                 COMPUTE L-SLOT = WS-LIST-SLOT(L-N) + 1
             END-IF
         WHEN OTHER
             IF L-N <= WS-SIZE
                 MOVE L-N TO L-SLOT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM HOPPER-FACE-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-KEY-IS.
*> USING item, key (PIC X(16), bare), flag out: 1 when the item has that key (with or without the minecraft: prefix).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-BARE                PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KEY                  PIC X(16).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-KEY L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "KEY-BARE" USING IT-KEY(L-ITEM + 1) WS-BARE
     IF WS-BARE = L-KEY
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM HOPPER-KEY-IS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-CAN-PLACE.
*> USING block entity index, slot (1 based), item, allowed out: the destination's canPlaceItem(slot, stack) (31-2 5.6; canPlaceItemThroughFace is the same). A furnace: the result slot never; the fuel
*> slot a fuel, or an empty bucket while the slot holds none (3.1); the input slot anything. A brewing stand: BE2-BREW-PLACE with the brewing_fuel, reagent and potion input tests of the stack
*> and whether the slot is empty (4.1). Every other container accepts any stack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CITEMS.
 01 WS-KIND                BINARY-LONG.
 01 WS-FUEL                BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-INPUT               BINARY-LONG.
 01 WS-REAGENT             BINARY-LONG.
 01 WS-USES                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-BREW-FUEL           BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-SLOT0               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 1.
 01 WS-BUCKET-KEY          PIC X(16) VALUE "bucket".
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-ITEM L-OK.
     MOVE 1 TO L-OK
     CALL "HOPPER-WORLDLY" USING BE-TYPE(L-INDEX) WS-KIND
     EVALUATE WS-KIND
         WHEN 1
             EVALUATE L-SLOT
                 WHEN 3
                     MOVE 0 TO L-OK
                 WHEN 2
                     CALL "FURN-MAY-FUEL" USING L-ITEM L-OK
                     CALL "HOPPER-KEY-IS" USING L-ITEM WS-BUCKET-KEY WS-BUCKET
                     MOVE 0 TO WS-HELD
                     IF BE-SLOT-COUNT(L-INDEX, 2) > 0
                         CALL "HOPPER-KEY-IS" USING BE-SLOT-ITEM(L-INDEX, 2) WS-BUCKET-KEY WS-HELD
                     END-IF
                     IF WS-BUCKET = 1 AND WS-HELD = 1
                         MOVE 0 TO L-OK
                     END-IF
             END-EVALUATE
         WHEN 2
             CALL "BREW-IS-INPUT" USING L-ITEM WS-INPUT
             CALL "BREW-IS-REAGENT" USING L-ITEM WS-REAGENT
             CALL "BREW-STAND-FUEL" USING L-ITEM WS-USES WS-SPEED
             MOVE 0 TO WS-BREW-FUEL
             IF WS-USES > 0
                 MOVE 1 TO WS-BREW-FUEL
             END-IF
             MOVE 0 TO WS-EMPTY
             IF BE-SLOT-COUNT(L-INDEX, L-SLOT) = 0
                 MOVE 1 TO WS-EMPTY
             END-IF
             COMPUTE WS-SLOT0 = L-SLOT - 1
             CALL "BE2-BREW-PLACE" USING WS-SLOT0 WS-BREW-FUEL WS-LEVEL WS-REAGENT WS-INPUT WS-EMPTY L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM HOPPER-CAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-CAN-TAKE.
*> USING block entity index, slot (1 based), item, face (0 down), allowed out: canTakeItemThroughFace(slot, stack, face) (31-2 3.1 and 4.1): a furnace's fuel slot below only gives a bucket or a
*> water bucket (the item tag furnace_fuel_bottom_takeable); a brewing stand's reagent slot only gives a glass bottle. Every other slot and container gives its stack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-GLASS               BINARY-LONG.
 01 WS-SLOT0               BINARY-LONG.
 01 WS-BUCKET-KEY          PIC X(16) VALUE "bucket".
 01 WS-WATER-KEY           PIC X(16) VALUE "water_bucket".
 01 WS-GLASS-KEY           PIC X(16) VALUE "glass_bottle".
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-ITEM L-FACE L-OK.
     MOVE 1 TO L-OK
     CALL "HOPPER-WORLDLY" USING BE-TYPE(L-INDEX) WS-KIND
     EVALUATE WS-KIND
         WHEN 1
             IF L-FACE = 0 AND L-SLOT = 2
                 CALL "HOPPER-KEY-IS" USING L-ITEM WS-BUCKET-KEY WS-BUCKET
                 CALL "HOPPER-KEY-IS" USING L-ITEM WS-WATER-KEY WS-WATER
                 MOVE 0 TO L-OK
                 IF WS-BUCKET = 1 OR WS-WATER = 1
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
         WHEN 2
             CALL "HOPPER-KEY-IS" USING L-ITEM WS-GLASS-KEY WS-GLASS
             COMPUTE WS-SLOT0 = L-SLOT - 1
             CALL "BE2-BREW-TAKE" USING WS-SLOT0 WS-GLASS L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM HOPPER-CAN-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-ADD-ONE.
*> USING block entity index, item, variant, face, left out (0 when one item went in): addItem(source, dest, stack, direction) of a single item (31-2 5.6): for each slot of getSlots(dest, face) in
*> order, the item goes into the slot that is empty or already holds the same stack with room (canMergeItems), when canPlaceItem allows it. The containers without face rules take the flat
*> insertion of RL-INSERT-ONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CITEMS.
 01 WS-KIND                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ITEM L-VAR L-FACE L-LEFT.
     CALL "HOPPER-WORLDLY" USING BE-TYPE(L-INDEX) WS-KIND
     IF WS-KIND = 0
         CALL "RL-INSERT-ONE" USING L-INDEX L-ITEM L-VAR L-LEFT
         GOBACK
     END-IF
     MOVE 1 TO L-LEFT
     CALL "BE-MAX-STACK" USING IT-MAX-STACK(L-ITEM + 1) WS-LIMIT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 5 OR L-LEFT = 0
         CALL "HOPPER-FACE-SLOT" USING L-INDEX L-FACE WS-N WS-SLOT
         IF WS-SLOT > 0
             CALL "HOPPER-CAN-PLACE" USING L-INDEX WS-SLOT L-ITEM WS-OK
             IF WS-OK = 1 AND BE-SLOT-COUNT(L-INDEX, WS-SLOT) = 0
                 MOVE L-ITEM TO BE-SLOT-ITEM(L-INDEX, WS-SLOT)
                 MOVE L-VAR TO BE-SLOT-VAR(L-INDEX, WS-SLOT)
                 MOVE 1 TO BE-SLOT-COUNT(L-INDEX, WS-SLOT)
                 MOVE 0 TO L-LEFT
             END-IF
             IF WS-OK = 1 AND L-LEFT = 1 AND BE-SLOT-ITEM(L-INDEX, WS-SLOT) = L-ITEM AND BE-SLOT-VAR(L-INDEX, WS-SLOT) = L-VAR
                     AND BE-SLOT-COUNT(L-INDEX, WS-SLOT) < WS-LIMIT
                 ADD 1 TO BE-SLOT-COUNT(L-INDEX, WS-SLOT)
                 MOVE 0 TO L-LEFT
             END-IF
         END-IF
     END-PERFORM
     IF L-LEFT = 0
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     GOBACK.
 END PROGRAM HOPPER-ADD-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-CONTAINER.
*> USING dim, x, y, z, block entity index out, size out: the container at the position that a hopper can move items into and out of (0 and 0 when there is none): a chest, trapped chest, barrel, shulker
*> box, dispenser, dropper or hopper block entity (31-2 5.7 step 1), or a furnace, smoker, blast furnace or brewing stand (slots by face, HOPPER-FACE-SLOT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-INDEX L-SIZE.
     MOVE 0 TO L-SIZE
     CALL "BE-FIND" USING L-DIM L-X L-Y L-Z L-INDEX
     IF L-INDEX > 0
         CALL "HOPPER-WORLDLY" USING BE-TYPE(L-INDEX) WS-KIND
         IF WS-KIND > 0 OR BE-TYPE(L-INDEX) = 1 OR BE-TYPE(L-INDEX) = 2 OR BE-TYPE(L-INDEX) = 5 OR BE-TYPE(L-INDEX) = 6
                 OR BE-TYPE(L-INDEX) = 18 OR BE-TYPE(L-INDEX) = 24 OR BE-TYPE(L-INDEX) = 26
             CALL "BE-CONTAINER-SIZE" USING BE-TYPE(L-INDEX) L-SIZE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HOPPER-CONTAINER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-EJECT.
*> USING hopper block entity index, state of the hopper block, moved out: ejectItems (5.4): one item of the first slot the container in front accepts, through the face opposite to the hopper's facing
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-TSIZE               BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-STATE L-MOVED.
     CALL "PST-FACING-OF" USING L-STATE WS-FACING
     CALL "BU-DIRECTION" USING WS-FACING WS-DX WS-DY WS-DZ
*>   side = facing.getOpposite(): a hopper facing down puts into the top of the container below, one facing a side into the side face
     IF WS-FACING = 0
         MOVE 1 TO WS-FACE
     ELSE
         MOVE 2 TO WS-FACE
     END-IF
     COMPUTE WS-QX = BE-X(L-INDEX) + WS-DX
     COMPUTE WS-QY = BE-Y(L-INDEX) + WS-DY
     COMPUTE WS-QZ = BE-Z(L-INDEX) + WS-DZ
     CALL "HOPPER-CONTAINER" USING BE-DIM(L-INDEX) WS-QX WS-QY WS-QZ WS-TARGET WS-TSIZE
     IF WS-TARGET > 0
         MOVE 1 TO WS-EMPTY
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-TSIZE
             IF BE-SLOT-COUNT(WS-TARGET, WS-S) > 0
                 MOVE 0 TO WS-EMPTY
             END-IF
         END-PERFORM
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 5 OR WS-DONE = 1
             IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
                 MOVE BE-SLOT-ITEM(L-INDEX, WS-S) TO WS-ITEM
                 MOVE BE-SLOT-VAR(L-INDEX, WS-S) TO WS-VAR
                 CALL "HOPPER-ADD-ONE" USING WS-TARGET WS-ITEM WS-VAR WS-FACE WS-LEFT
                 IF WS-LEFT = 0
                     SUBTRACT 1 FROM BE-SLOT-COUNT(L-INDEX, WS-S)
                     IF BE-SLOT-COUNT(L-INDEX, WS-S) = 0
                         MOVE 0 TO BE-SLOT-ITEM(L-INDEX, WS-S)
                         MOVE 0 TO BE-SLOT-VAR(L-INDEX, WS-S)
                     END-IF
                     MOVE 1 TO L-MOVED
                     MOVE 1 TO WS-DONE
*>                   a hopper that was empty and not on a custom cooldown waits 8 (7 when this hopper ticked no later than it did, 5.6)
                     IF WS-EMPTY = 1 AND BE-TYPE(WS-TARGET) = 18 AND BE-COOLDOWN(WS-TARGET) <= 8
                         MOVE 0 TO WS-OFFSET
                         IF BE-TIME2(WS-TARGET) >= BE-TIME2(L-INDEX)
                             MOVE 1 TO WS-OFFSET
                         END-IF
                         COMPUTE BE-COOLDOWN(WS-TARGET) = 8 - WS-OFFSET
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM HOPPER-EJECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-SUCK.
*> USING hopper block entity index, moved out: suckInItems (5.5): one item from the first slot of getSlots(source, DOWN) of the container above that the hopper accepts and the source lets go
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-SSIZE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-MOVED.
     COMPUTE WS-QY = BE-Y(L-INDEX) + 1
     CALL "HOPPER-CONTAINER" USING BE-DIM(L-INDEX) BE-X(L-INDEX) WS-QY BE-Z(L-INDEX) WS-SOURCE WS-SSIZE
     IF WS-SOURCE > 0
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-SSIZE OR WS-DONE = 1
             CALL "HOPPER-FACE-SLOT" USING WS-SOURCE WS-DOWN WS-N WS-S
             MOVE 0 TO WS-OK
             IF WS-S > 0 AND BE-SLOT-COUNT(WS-SOURCE, WS-S) > 0
                 CALL "HOPPER-CAN-TAKE" USING WS-SOURCE WS-S BE-SLOT-ITEM(WS-SOURCE, WS-S) WS-DOWN WS-OK
             END-IF
             IF WS-OK = 1
                 MOVE BE-SLOT-ITEM(WS-SOURCE, WS-S) TO WS-ITEM
                 MOVE BE-SLOT-VAR(WS-SOURCE, WS-S) TO WS-VAR
                 CALL "RL-INSERT-ONE" USING L-INDEX WS-ITEM WS-VAR WS-LEFT
                 IF WS-LEFT = 0
                     SUBTRACT 1 FROM BE-SLOT-COUNT(WS-SOURCE, WS-S)
                     IF BE-SLOT-COUNT(WS-SOURCE, WS-S) = 0
                         MOVE 0 TO BE-SLOT-ITEM(WS-SOURCE, WS-S)
                         MOVE 0 TO BE-SLOT-VAR(WS-SOURCE, WS-S)
                     END-IF
                     CALL "BE-MARK-CHUNK" USING WS-SOURCE
                     MOVE 1 TO L-MOVED
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM HOPPER-SUCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-TICK.
*> USING hopper block entity index: pushItemsTick (5.3): the cooldown counts down; off cooldown and enabled, eject then suck in; a move sets the cooldown 8
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CITEMS.
 01 WS-ENABLED             PIC X(16) VALUE "enabled".
 01 WS-S                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     SUBTRACT 1 FROM BE-COOLDOWN(L-INDEX)
     MOVE CW-TICKS TO BE-TIME2(L-INDEX)
     IF BE-COOLDOWN(L-INDEX) <= 0
         MOVE 0 TO BE-COOLDOWN(L-INDEX)
         CALL "WORLD-GET-BLOCK" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-STATE
         CALL "RL-GET-BOOL" USING WS-STATE WS-ENABLED WS-ON
         IF WS-ON = 1
             MOVE 0 TO WS-MOVED WS-HAS
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 5
                 IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
                     MOVE 1 TO WS-HAS
                 END-IF
             END-PERFORM
             IF WS-HAS = 1
                 CALL "HOPPER-EJECT" USING L-INDEX WS-STATE WS-MOVED
             END-IF
             MOVE 1 TO WS-FULL
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 5
                 IF BE-SLOT-COUNT(L-INDEX, WS-S) = 0
                     MOVE 0 TO WS-FULL
                 ELSE
                     MOVE IT-MAX-STACK(BE-SLOT-ITEM(L-INDEX, WS-S) + 1) TO WS-LIMIT
                     IF BE-SLOT-COUNT(L-INDEX, WS-S) < WS-LIMIT
                         MOVE 0 TO WS-FULL
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-FULL = 0
                 CALL "HOPPER-SUCK" USING L-INDEX WS-MOVED
             END-IF
             IF WS-MOVED = 1
                 MOVE 8 TO BE-COOLDOWN(L-INDEX)
                 CALL "BE-MARK-CHUNK" USING L-INDEX
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HOPPER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOPPER-TICK-ALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) > 0 AND BE-TYPE(WS-I) = 18
             CALL "HOPPER-TICK" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HOPPER-TICK-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-HOOK-EMIT.
*> USING dim, x, y, z of a hook, attached, powered, was attached, was powered: emitState (30-8 7.4): the click, attach or detach sound of the first matching transition and the game event (a vibration the sculk
*> sensors can hear).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-PITCH               BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-VOLUME              BINARY-LONG.
 01 WS-SOUND-EVENT         BINARY-LONG.
 01 WS-KEY                 PIC X(48) VALUE "tripwire_hook".
 01 WS-NAME                PIC X(24).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ATTACHED             BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-WAS-A                BINARY-LONG.
 01 L-WAS-P                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ATTACHED L-POWERED L-WAS-A L-WAS-P.
     CALL "RS3-HOOK-EMIT" USING L-ATTACHED L-POWERED L-WAS-A L-WAS-P WS-KIND WS-PITCH WS-EVENT WS-VOLUME
     IF WS-KIND > 0
         COMPUTE WS-SOUND-EVENT = WS-KIND + 6
         CALL "RL-BLOCK-SOUND" USING L-DIM L-X L-Y L-Z WS-KEY WS-SOUND-EVENT
         EVALUATE WS-EVENT
             WHEN 1
                 MOVE "block_activate" TO WS-NAME
             WHEN 2
                 MOVE "block_deactivate" TO WS-NAME
             WHEN 3
                 MOVE "block_attach" TO WS-NAME
             WHEN OTHER
                 MOVE "block_detach" TO WS-NAME
         END-EVALUATE
         CALL "VIB-POST" USING L-DIM L-X L-Y L-Z WS-NAME
     END-IF
     GOBACK.
 END PROGRAM RL-HOOK-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-OPEN-EFFECTS.
*> USING dim, x, y, z, the state now (open or closed), class (9 trapdoor, 12 door, 13 fence gate), sound (1 play it), water (1 a waterlogged trapdoor schedules its water tick): the click of an opening
*> or closing (30-7 section 1 rule 2) and the water tick of a trapdoor that is waterlogged (4.2 toggle and neighborChanged: FlowingFluid.getTickDelay of water is 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-OPEN-NAME           PIC X(16) VALUE "open".
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-OPEN                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-CLASS L-SOUND L-WATER.
     IF L-SOUND = 1
         MOVE CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-KEY
         CALL "KEY-BARE" USING WS-KEY WS-BARE
         CALL "RL-GET-BOOL" USING L-STATE WS-OPEN-NAME WS-OPEN
         COMPUTE WS-EVENT = 2 - WS-OPEN
         CALL "RL-BLOCK-SOUND" USING L-DIM L-X L-Y L-Z WS-BARE WS-EVENT
         IF WS-OPEN = 1
             MOVE "block_open" TO WS-KEY
         ELSE
             MOVE "block_close" TO WS-KEY
         END-IF
         CALL "VIB-POST" USING L-DIM L-X L-Y L-Z WS-KEY
     END-IF
     IF L-WATER = 1 AND L-CLASS = 9
         CALL "FLUID-OF-STATE" USING L-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
         CALL "FLUID-SCHEDULE" USING L-DIM L-X L-Y L-Z WS-FLUID WS-DELAY
     END-IF
     GOBACK.
 END PROGRAM RL-OPEN-EFFECTS.
