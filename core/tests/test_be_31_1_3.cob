*> Test of 31 section 3 (BlockEntityType and the registry; T0845): 49 types with ids 0 to 48 in registration order, the key of
*> each, the valid block set of each type (families: copper chests, signs, hanging signs, skulls, banners, shulker boxes, shelves,
*> copper golem statues), and the six operator-only types of 3.2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE10              BINARY-LONG VALUE 10.
 01 WS-ROWS.
    05 FILLER PIC X(51) VALUE "01minecraft:chest                                 1".
    05 FILLER PIC X(51) VALUE "01minecraft:waxed_weathered_copper_chest          1".
    05 FILLER PIC X(51) VALUE "01minecraft:exposed_copper_chest                  1".
    05 FILLER PIC X(51) VALUE "01minecraft:trapped_chest                         0".
    05 FILLER PIC X(51) VALUE "02minecraft:trapped_chest                         1".
    05 FILLER PIC X(51) VALUE "03minecraft:ender_chest                           1".
    05 FILLER PIC X(51) VALUE "07minecraft:dark_oak_wall_sign                    1".
    05 FILLER PIC X(51) VALUE "07minecraft:oak_hanging_sign                      0".
    05 FILLER PIC X(51) VALUE "08minecraft:pale_oak_wall_hanging_sign            1".
    05 FILLER PIC X(51) VALUE "08minecraft:oak_sign                              0".
    05 FILLER PIC X(51) VALUE "07minecraft:poplar_sign                           1".
    05 FILLER PIC X(51) VALUE "16minecraft:piglin_wall_head                      1".
    05 FILLER PIC X(51) VALUE "16minecraft:zombie_head                           1".
    05 FILLER PIC X(51) VALUE "16minecraft:skeleton_head                         0".
    05 FILLER PIC X(51) VALUE "20minecraft:light_gray_wall_banner                1".
    05 FILLER PIC X(51) VALUE "20minecraft:banner                                0".
    05 FILLER PIC X(51) VALUE "24minecraft:shulker_box                           1".
    05 FILLER PIC X(51) VALUE "24minecraft:cyan_shulker_box                      1".
    05 FILLER PIC X(51) VALUE "24minecraft:cyan_box                              0".
    05 FILLER PIC X(51) VALUE "23minecraft:chain_command_block                   1".
    05 FILLER PIC X(51) VALUE "23minecraft:command_block                         1".
    05 FILLER PIC X(51) VALUE "32minecraft:soul_campfire                         1".
    05 FILLER PIC X(51) VALUE "33minecraft:bee_nest                              1".
    05 FILLER PIC X(51) VALUE "39minecraft:bamboo_shelf                          1".
    05 FILLER PIC X(51) VALUE "39minecraft:shelf                                 0".
    05 FILLER PIC X(51) VALUE "40minecraft:suspicious_gravel                     1".
    05 FILLER PIC X(51) VALUE "47minecraft:waxed_oxidized_copper_golem_statue    1".
    05 FILLER PIC X(51) VALUE "47minecraft:copper_golem_statue                   1".
    05 FILLER PIC X(51) VALUE "00minecraft:furnace                               1".
    05 FILLER PIC X(51) VALUE "00minecraft:smoker                                0".
    05 FILLER PIC X(51) VALUE "09minecraft:spawner                               1".
    05 FILLER PIC X(51) VALUE "11minecraft:moving_piston                         1".
    05 FILLER PIC X(51) VALUE "48minecraft:potent_sulfur                         1".
    05 FILLER PIC X(51) VALUE "26minecraft:barrel                                1".
    05 FILLER PIC X(51) VALUE "01stone                                           0".
    05 FILLER PIC X(51) VALUE "99minecraft:chest                                 0".
    05 FILLER PIC X(51) VALUE "12minecraft:brewing_stand                         1".
    05 FILLER PIC X(51) VALUE "05minecraft:dispenser                             1".
    05 FILLER PIC X(51) VALUE "17minecraft:daylight_detector                     1".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 39 TIMES.
       10 WS-ROW-TYPE PIC 99.
       10 WS-ROW-KEY PIC X(48).
       10 WS-ROW-OK PIC 9.
 01 WS-ROW-COUNT BINARY-LONG VALUE 39.
 01 WS-BAD BINARY-LONG.
 01 WS-GOT BINARY-LONG.
 01 WS-TYPE BINARY-LONG.
 01 WS-KEYLEN BINARY-LONG.
 01 WS-KEY PIC X(48).
 01 WS-OP BINARY-LONG.
 01 WS-OPS BINARY-LONG.
 01 WS-OPLIST PIC X(120).
 01 WS-K24 PIC X(24).
 01 WS-PTR BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "acceptance US12 31-1§3 registry: ids 0, 1, 24, 26 and 48 are furnace, chest, shulker_box, barrel and potent_sulfur" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-TYPE FROM 0 BY 1 UNTIL WS-TYPE > 48
         CALL "BE-TYPE-INFO" USING WS-TYPE WS-K24 WS-KEYLEN WS-OP
         IF WS-TYPE = 0 OR WS-TYPE = 1 OR WS-TYPE = 24 OR WS-TYPE = 26 OR WS-TYPE = 48
             STRING WS-K24(1:WS-KEYLEN) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "furnace chest shulker_box barrel potent_sulfur" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§3 registry: BE-TYPE-ID finds a key and answers -1 for an unknown one" TO TL-CASE
     MOVE "shulker_box" TO WS-K24
     MOVE 11 TO WS-KEYLEN
     CALL "BE-TYPE-ID" USING WS-K24 WS-KEYLEN WS-TYPE
     MOVE WS-TYPE TO WS-EDIT
     MOVE "nope" TO WS-K24
     MOVE 4 TO WS-KEYLEN
     CALL "BE-TYPE-ID" USING WS-K24 WS-KEYLEN WS-TYPE
     MOVE WS-TYPE TO WS-EDIT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "24 -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§3 registry: exactly six types are operator-only (3.2): sign, hanging_sign, mob_spawner, command_block, lectern, trial_spawner" TO TL-CASE
     MOVE 0 TO WS-OPS
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-TYPE FROM 0 BY 1 UNTIL WS-TYPE > 48
         CALL "BE-TYPE-INFO" USING WS-TYPE WS-K24 WS-KEYLEN WS-OP
         IF WS-OP = 1
             ADD 1 TO WS-OPS
             STRING WS-K24(1:WS-KEYLEN) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE WS-OPS TO WS-EDIT
     MOVE SPACES TO WS-OPLIST
     STRING FUNCTION TRIM(WS-EDIT) " " WS-TEXT(1:WS-PTR - 1) DELIMITED BY SIZE INTO WS-OPLIST
     MOVE WS-OPLIST TO WS-TEXT
     MOVE "6 sign hanging_sign mob_spawner command_block lectern trial_spawner" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§3 registry: the valid block set of each type (families and exact keys, 39 sample rows)" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-ROW-COUNT
         MOVE WS-ROW-TYPE(WS-I) TO WS-TYPE
         MOVE WS-ROW-KEY(WS-I) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEYLEN
         CALL "BE-VALID-BLOCK" USING WS-TYPE WS-KEY WS-KEYLEN WS-GOT
         IF WS-GOT NOT = WS-ROW-OK(WS-I)
             ADD 1 TO WS-BAD
             DISPLAY "bad row " WS-I " " WS-ROW-KEY(WS-I)
         END-IF
     END-PERFORM
     MOVE WS-BAD TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-3.

 COPY CORETEST.
