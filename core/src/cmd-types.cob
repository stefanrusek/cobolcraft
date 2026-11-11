*> The argument types of docs/protocol/15-commands-framework.md §6 (grammar, wire id, properties, results) that the
*> framework parses itself, beyond the stock Brigadier types of cmd-reader.cob: the enumerations (§6.2), uuid (§6.3),
*> the scoreboard types (§6.4), item slots (§6.6), resource locations and the registry types (§6.7), function (§6.8),
*> ranges (§6.9) and time (§6.10). The entity, coordinate and NBT families are cmd-selector.cob, cmd-coords.cob and
*> cmd-snbt.cob; BR-ARG-EXT dispatches to all of them. An id that no module handles (particle, slot_source) reads one word.
*> Parsing is syntactic: a name that names nothing (an unknown effect, advancement, function, dimension) is the
*> command's error at execution (15 §6.7 "not found"), so the argument value is the text range of the trail entry.
*>
*> Entry points:
*>   BR-ARG-EXT USING node, integer out, double out, infinity flag out: the argument of the node's parser id from
*>     BR-IN-CURSOR (as BR-ARG-PARSE); on success the cursor is after it and BR-VAL (core/copy/BRIGADIER.cpy) holds
*>     what the type leaves in the trail: an enumeration, hex colour, time (ticks) or operation as the integer
*>     value; slots (first slot, count in BR-V-IVAL2); ranges (BR-V-AUX 1 minimum, 2 maximum, 3 both; the bounds in
*>     the integer or double and the second integer or double)
*>   BR-ENUM-INDEX USING list (PIC X(400), names separated by single spaces), text, length, index out (0-based, -1 none)
*>   BR-SLOT-LOOKUP USING text, length, count out (0 = unknown name), slots out (BINARY-LONG table of 64)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ENUM-INDEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-WORD-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIST                 PIC X(400).
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-TEXT L-LENGTH L-INDEX.
     MOVE -1 TO L-INDEX
     MOVE 1 TO WS-POS
     MOVE 0 TO WS-INDEX
     PERFORM UNTIL WS-POS > 400 OR L-LIST(WS-POS:1) = SPACE OR L-INDEX >= 0
         MOVE WS-POS TO WS-END
         PERFORM UNTIL WS-END > 400 OR L-LIST(WS-END:1) = SPACE
             ADD 1 TO WS-END
         END-PERFORM
         COMPUTE WS-WORD-LENGTH = WS-END - WS-POS
         IF WS-WORD-LENGTH = L-LENGTH AND L-LENGTH > 0
                 AND L-LIST(WS-POS:WS-WORD-LENGTH) = L-TEXT(1:L-LENGTH)
             MOVE WS-INDEX TO L-INDEX
         END-IF
         ADD 1 TO WS-INDEX
         COMPUTE WS-POS = WS-END + 1
     END-PERFORM
     GOBACK.
 END PROGRAM BR-ENUM-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SLOT-LOOKUP.
*> The slot names of 15 §6.6: a fixed name, or prefix.N for the prefixes of the table (container 0 to 53 from slot
*> 0, hotbar 0 to 8 from 0, inventory 0 to 26 from 9, enderchest 0 to 26 from 200, mob.inventory 0 to 7 from 300,
*> horse 0 to 14 from 500, player.crafting 0 to 3 from 500), or prefix.* (all N, in order). N has no leading zero.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PREFIXES.
    05 FILLER PIC X(16) VALUE "container".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 53.
    05 FILLER PIC X(16) VALUE "hotbar".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER PIC X(16) VALUE "inventory".
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 26.
    05 FILLER PIC X(16) VALUE "enderchest".
    05 FILLER BINARY-LONG VALUE 200.
    05 FILLER BINARY-LONG VALUE 26.
    05 FILLER PIC X(16) VALUE "mob.inventory".
    05 FILLER BINARY-LONG VALUE 300.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER PIC X(16) VALUE "horse".
    05 FILLER BINARY-LONG VALUE 500.
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER PIC X(16) VALUE "player.crafting".
    05 FILLER BINARY-LONG VALUE 500.
    05 FILLER BINARY-LONG VALUE 3.
 01 WS-PREFIX-TABLE REDEFINES WS-PREFIXES.
    05 WS-PREFIX OCCURS 7 TIMES.
       10 WS-P-NAME          PIC X(16).
       10 WS-P-BASE          BINARY-LONG.
       10 WS-P-MAX           BINARY-LONG.
 01 WS-FIXED.
    05 FILLER PIC X(16) VALUE "contents".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(16) VALUE "weapon".
    05 FILLER BINARY-LONG VALUE 98.
    05 FILLER PIC X(16) VALUE "weapon.mainhand".
    05 FILLER BINARY-LONG VALUE 98.
    05 FILLER PIC X(16) VALUE "weapon.offhand".
    05 FILLER BINARY-LONG VALUE 99.
    05 FILLER PIC X(16) VALUE "armor.feet".
    05 FILLER BINARY-LONG VALUE 100.
    05 FILLER PIC X(16) VALUE "armor.legs".
    05 FILLER BINARY-LONG VALUE 101.
    05 FILLER PIC X(16) VALUE "armor.chest".
    05 FILLER BINARY-LONG VALUE 102.
    05 FILLER PIC X(16) VALUE "armor.head".
    05 FILLER BINARY-LONG VALUE 103.
    05 FILLER PIC X(16) VALUE "armor.body".
    05 FILLER BINARY-LONG VALUE 105.
    05 FILLER PIC X(16) VALUE "saddle".
    05 FILLER BINARY-LONG VALUE 106.
    05 FILLER PIC X(16) VALUE "horse.chest".
    05 FILLER BINARY-LONG VALUE 499.
    05 FILLER PIC X(16) VALUE "player.cursor".
    05 FILLER BINARY-LONG VALUE 499.
 01 WS-FIXED-TABLE REDEFINES WS-FIXED.
    05 WS-FX OCCURS 12 TIMES.
       10 WS-FX-NAME         PIC X(16).
       10 WS-FX-SLOT         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DOT                 BINARY-LONG.
 01 WS-TAIL-LENGTH         BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-DIGIT-OK            BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SLOTS.
    05 L-SLOT              BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-COUNT L-SLOTS.
     GO TO MAIN-LINE.

*> The text is prefix "." tail; the dot is the last one.
 PREFIXED.
     MOVE 0 TO WS-DOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         IF L-TEXT(WS-I:1) = "."
             MOVE WS-I TO WS-DOT
         END-IF
     END-PERFORM
     IF L-TEXT(1:L-LENGTH) = "weapon.*"
         MOVE 2 TO L-COUNT
         MOVE 98 TO L-SLOT(1)
         MOVE 99 TO L-SLOT(2)
     ELSE
         IF L-TEXT(1:L-LENGTH) = "armor.*"
             MOVE 5 TO L-COUNT
             MOVE 103 TO L-SLOT(1)
             MOVE 102 TO L-SLOT(2)
             MOVE 101 TO L-SLOT(3)
             MOVE 100 TO L-SLOT(4)
             MOVE 105 TO L-SLOT(5)
         ELSE
             IF WS-DOT > 1 AND WS-DOT < L-LENGTH AND WS-DOT <= 16
                 PERFORM TABLE-PREFIX
             END-IF
         END-IF
     END-IF.

 TABLE-PREFIX.
     MOVE SPACES TO WS-NAME
     MOVE L-TEXT(1:WS-DOT - 1) TO WS-NAME
     COMPUTE WS-TAIL-LENGTH = L-LENGTH - WS-DOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         IF WS-P-NAME(WS-I) = WS-NAME
             PERFORM TAIL-OF-PREFIX
         END-IF
     END-PERFORM.

*> The tail is * (every slot of the prefix) or a number from 0 to the maximum without a leading zero.
 TAIL-OF-PREFIX.
     IF L-TEXT(WS-DOT + 1:WS-TAIL-LENGTH) = "*"
         COMPUTE L-COUNT = WS-P-MAX(WS-I) + 1
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > L-COUNT
             COMPUTE L-SLOT(WS-N) = WS-P-BASE(WS-I) + WS-N - 1
         END-PERFORM
     ELSE
         MOVE 1 TO WS-DIGIT-OK
         MOVE 0 TO WS-N
         IF WS-TAIL-LENGTH > 2 OR (WS-TAIL-LENGTH = 2 AND L-TEXT(WS-DOT + 1:1) = "0")
             MOVE 0 TO WS-DIGIT-OK
         END-IF
         IF WS-DIGIT-OK = 1
             IF L-TEXT(WS-DOT + 1:WS-TAIL-LENGTH) IS NUMERIC
                 MOVE L-TEXT(WS-DOT + 1:WS-TAIL-LENGTH) TO WS-N
                 IF WS-N <= WS-P-MAX(WS-I)
                     MOVE 1 TO L-COUNT
                     COMPUTE L-SLOT(1) = WS-P-BASE(WS-I) + WS-N
                 END-IF
             END-IF
         END-IF
     END-IF.
 

 MAIN-LINE.
     MOVE 0 TO L-COUNT
     IF L-LENGTH > 16 AND L-LENGTH > 0
         PERFORM PREFIXED
     ELSE
         MOVE SPACES TO WS-NAME
         MOVE L-TEXT(1:L-LENGTH) TO WS-NAME
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
             IF WS-FX-NAME(WS-I) = WS-NAME AND L-LENGTH > 0
                 MOVE 1 TO L-COUNT
                 MOVE WS-FX-SLOT(WS-I) TO L-SLOT(1)
             END-IF
         END-PERFORM
         IF L-COUNT = 0
             PERFORM PREFIXED
         END-IF
     END-IF
     GOBACK.
END PROGRAM BR-SLOT-LOOKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ARG-EXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY CONTENT.
 01 WS-REG-KEY             PIC X(112).
 01 WS-REG-COUNT           BINARY-LONG.
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-REG-ID              BINARY-LONG.
 01 WS-REG-ENTRY           PIC X(112).
 01 WS-REG-ENTRY-LENGTH    BINARY-LONG.
 01 WS-REG-PAYLOAD         PIC X.
 01 WS-REG-CAPACITY        BINARY-LONG VALUE 0.
 01 WS-REG-PAYLOAD-LENGTH  BINARY-LONG.
 01 WS-REG-WANT            PIC X(112).
 01 WS-REG-WANT-LENGTH     BINARY-LONG.
 01 WS-REG-ALT             PIC X(112).
 01 WS-REG-ALT-LENGTH      BINARY-LONG.
 01 WS-REG-FOUND           BINARY-LONG.
 01 WS-REG-HAS-COLON       BINARY-LONG.
 01 WS-LISTS.
    05 WS-L-GAMEMODE        PIC X(400) VALUE "survival creative adventure spectator".
    05 WS-L-ANCHOR          PIC X(400) VALUE "feet eyes".
    05 WS-L-MIRROR          PIC X(400) VALUE "none left_right front_back".
    05 WS-L-TEMPLATE-ROT    PIC X(400) VALUE "none clockwise_90 180 counterclockwise_90".
    05 WS-L-HEIGHTMAP       PIC X(400)
        VALUE "world_surface ocean_floor motion_blocking motion_blocking_no_leaves".
    05 WS-L-SWING           PIC X(400) VALUE "none whack stab".
    05 WS-L-COLOR           PIC X(400)
        VALUE "black dark_blue dark_green dark_aqua dark_red dark_purple gold gray dark_gray blue green aqua red light_pu"
         & "rple yellow white".
    05 WS-L-DISPLAY         PIC X(400)
        VALUE "list sidebar below_name sidebar.team.black sidebar.team.dark_blue sidebar.team.dark_green sidebar.team.dar"
         & "k_aqua sidebar.team.dark_red sidebar.team.dark_purple sidebar.team.gold sidebar.team.gray sidebar.team.dark_gray si"
         & "debar.team.blue sidebar.team.green sidebar.team.aqua sidebar.team.red sidebar.team.light_purple sidebar.team.yellow"
         & " sidebar.team.white".
    05 WS-L-OPERATION       PIC X(400) VALUE "= += -= *= /= %= < > ><".
    05 WS-L-STATS           PIC X(400)
        VALUE "minecraft.mined minecraft.broken minecraft.crafted minecraft.used minecraft.picked_up minecraft.dropped mi"
         & "necraft.killed minecraft.killed_by minecraft.custom".
    05 WS-L-CRITERIA        PIC X(400)
        VALUE "dummy trigger deathCount playerKillCount totalKillCount health food air armor xp level".
 01 WS-START               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STR                 PIC X(1024).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND-FLOAT          BINARY-LONG VALUE 1.
 01 WS-KIND-DOUBLE         BINARY-LONG VALUE 2.
 01 WS-RESET-ON-FAIL       BINARY-LONG.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-INF                 BINARY-LONG.
 01 WS-UNIT                BINARY-LONG.
 01 WS-PRODUCT             FLOAT-LONG.
 01 WS-ABS                 FLOAT-LONG.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-MIN-TICKS           BINARY-DOUBLE.
 01 WS-EDIT                PIC -(19)9.
 01 WS-SIGN                BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-GROUP-DIGITS        BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-HAS-COLON           BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-RUN-START           BINARY-LONG.
 01 WS-RUN-END             BINARY-LONG.
 01 WS-RUN-1-START         BINARY-LONG.
 01 WS-RUN-1-END           BINARY-LONG.
 01 WS-RUN-2-START         BINARY-LONG.
 01 WS-RUN-2-END           BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-SLOT-COUNT          BINARY-LONG.
 01 WS-SLOTS.
    05 WS-SLOT              BINARY-LONG OCCURS 64 TIMES.
 01 WS-MIN-RUN             BINARY-LONG.
 01 WS-HEX-VALUE           BINARY-LONG.
 01 WS-HEX-DIGIT           BINARY-LONG.
 01 WS-PATTERN             BINARY-LONG.
 01 WS-PART-START          BINARY-LONG.
 01 WS-PART-END            BINARY-LONG.
 01 WS-PART-KIND           BINARY-LONG.
 01 WS-SNBT-KIND           BINARY-LONG.
 01 WS-TAIL                PIC X(1024).
 01 WS-ID-FLAGS            BINARY-LONG.
 01 WS-ID-START            BINARY-LONG.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-RANGE-KIND          BINARY-LONG.
 01 WS-RANGE-AUX           BINARY-LONG.
 01 WS-RANGE-I2            BINARY-DOUBLE.
 01 WS-RANGE-D2            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-INT                  BINARY-DOUBLE.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-INF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-INT L-DOUBLE L-INF.
     GO TO MAIN-LINE.

 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

*> The text from WS-RUN-START for WS-STR-LENGTH characters as the one argument (at most 64), cursor WS-RC.
 RAISE-TEXT.
     MOVE 1 TO WS-N-ARGS
     MOVE SPACES TO WS-A1
     MOVE WS-STR-LENGTH TO WS-L1
     IF WS-L1 > 64
         MOVE 64 TO WS-L1
     END-IF
     IF WS-L1 > 0
         MOVE BR-IN-TEXT(WS-RUN-START + 1:WS-L1) TO WS-A1(1:WS-L1)
     END-IF
     PERFORM RAISE-NOW.

 RAISE-PLAIN.
     MOVE 0 TO WS-N-ARGS
     PERFORM RAISE-NOW.

*> ---- enumerations (§6.2) ------------------------------------------------------------------
*> An unquoted run looked up exactly; an unknown one leaves the cursor after the run, entity_anchor resets it.
 DO-ENUM.
     MOVE BR-IN-CURSOR TO WS-START
     MOVE WS-START TO WS-C
     CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
     MOVE WS-START TO WS-RUN-START
     MOVE 0 TO WS-RESET-ON-FAIL
     EVALUATE BR-N-TYPE(L-NODE)
         WHEN BR-P-GAMEMODE
             CALL "BR-ENUM-INDEX" USING WS-L-GAMEMODE WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.gamemode.invalid" TO WS-KEY
         WHEN BR-P-ANCHOR
             CALL "BR-ENUM-INDEX" USING WS-L-ANCHOR WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.anchor.invalid" TO WS-KEY
             MOVE 1 TO WS-RESET-ON-FAIL
         WHEN BR-P-MIRROR
             CALL "BR-ENUM-INDEX" USING WS-L-MIRROR WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.enum.invalid" TO WS-KEY
         WHEN BR-P-TEMPLATE-ROT
             CALL "BR-ENUM-INDEX" USING WS-L-TEMPLATE-ROT WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.enum.invalid" TO WS-KEY
         WHEN BR-P-HEIGHTMAP
             CALL "BR-ENUM-INDEX" USING WS-L-HEIGHTMAP WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.enum.invalid" TO WS-KEY
         WHEN BR-P-SWING
             CALL "BR-ENUM-INDEX" USING WS-L-SWING WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.swing_animation.invalid" TO WS-KEY
         WHEN BR-P-SLOT-DISPLAY
             CALL "BR-ENUM-INDEX" USING WS-L-DISPLAY WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.scoreboardDisplaySlot.invalid" TO WS-KEY
         WHEN OTHER
             CALL "BR-ENUM-INDEX" USING WS-L-COLOR WS-STR WS-STR-LENGTH WS-INDEX
             MOVE "argument.color.invalid" TO WS-KEY
     END-EVALUATE
     IF WS-INDEX >= 0
         MOVE WS-INDEX TO L-INT
         MOVE WS-C TO BR-IN-CURSOR
     ELSE
         MOVE WS-C TO WS-RC
         IF WS-RESET-ON-FAIL = 1
             MOVE WS-START TO WS-RC
         END-IF
         PERFORM RAISE-TEXT
     END-IF.

*> hex_color: exactly 3 or 6 hexadecimal digits; 3 digits are doubled each.
 DO-HEX.
     MOVE BR-IN-CURSOR TO WS-START
     MOVE WS-START TO WS-C
     CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
     MOVE WS-START TO WS-RUN-START
     MOVE 1 TO WS-VALID
     MOVE 0 TO WS-HEX-VALUE
     IF WS-STR-LENGTH NOT = 3 AND WS-STR-LENGTH NOT = 6
         MOVE 0 TO WS-VALID
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-STR-LENGTH OR WS-VALID = 0
         MOVE WS-STR(WS-I:1) TO WS-CH
         EVALUATE TRUE
             WHEN WS-CH >= "0" AND WS-CH <= "9"
                 COMPUTE WS-HEX-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("0")
             WHEN WS-CH >= "a" AND WS-CH <= "f"
                 COMPUTE WS-HEX-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("a") + 10
             WHEN WS-CH >= "A" AND WS-CH <= "F"
                 COMPUTE WS-HEX-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("A") + 10
             WHEN OTHER
                 MOVE 0 TO WS-VALID
         END-EVALUATE
         IF WS-VALID = 1
             IF WS-STR-LENGTH = 3
                 COMPUTE WS-HEX-VALUE = WS-HEX-VALUE * 256 + WS-HEX-DIGIT * 17
             ELSE
                 COMPUTE WS-HEX-VALUE = WS-HEX-VALUE * 16 + WS-HEX-DIGIT
             END-IF
         END-IF
     END-PERFORM
     IF WS-VALID = 1
         MOVE WS-HEX-VALUE TO L-INT
         MOVE WS-C TO BR-IN-CURSOR
     ELSE
         MOVE "argument.hexcolor.invalid" TO WS-KEY
         MOVE WS-C TO WS-RC
         PERFORM RAISE-TEXT
     END-IF.

*> ---- time (§6.10): a float, then an unquoted run as the unit ----------------------------------------
 DO-TIME.
     CALL "BR-READ-PLAIN" USING WS-KIND-FLOAT WS-INT WS-DOUBLE WS-INF
     IF BR-E-KEY = SPACES
         MOVE BR-IN-CURSOR TO WS-C
         CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
         MOVE 0 TO WS-UNIT
         EVALUATE TRUE
             WHEN WS-STR-LENGTH = 0
             WHEN WS-STR(1:WS-STR-LENGTH) = "t"
                 MOVE 1 TO WS-UNIT
             WHEN WS-STR(1:WS-STR-LENGTH) = "s"
                 MOVE 20 TO WS-UNIT
             WHEN WS-STR(1:WS-STR-LENGTH) = "d"
                 MOVE 24000 TO WS-UNIT
         END-EVALUATE
         MOVE WS-C TO BR-IN-CURSOR
         IF WS-UNIT = 0
             MOVE "argument.time.invalid_unit" TO WS-KEY
             MOVE WS-C TO WS-RC
             PERFORM RAISE-PLAIN
         ELSE
             PERFORM TICKS-OF-TIME
         END-IF
     END-IF.

*> Math.round of the product (floor of x + 1/2, saturating as an int), then the minimum of the property. A magnitude
*> above 90000 times a unit of at least 1 is already past 32 bits (and a float of that size may be infinite).
 TICKS-OF-TIME.
     COMPUTE WS-ABS = FUNCTION ABS(WS-DOUBLE)
     EVALUATE TRUE
         WHEN WS-INF = 1 OR WS-ABS > 90000
             IF WS-DOUBLE < 0
                 MOVE -2147483648 TO WS-TICKS
             ELSE
                 MOVE 2147483647 TO WS-TICKS
             END-IF
         WHEN OTHER
             COMPUTE WS-PRODUCT = WS-DOUBLE * WS-UNIT
             COMPUTE WS-TICKS = FUNCTION INTEGER(WS-PRODUCT + 0.5)
     END-EVALUATE
     IF WS-TICKS > 2147483647
         MOVE 2147483647 TO WS-TICKS
     END-IF
     MOVE 0 TO WS-MIN-TICKS
     IF BR-N-HAS-MIN(L-NODE) = 1
         MOVE BR-N-IMIN(L-NODE) TO WS-MIN-TICKS
     END-IF
     IF WS-TICKS < WS-MIN-TICKS
         MOVE "argument.time.tick_count_too_low" TO WS-KEY
         MOVE 2 TO WS-N-ARGS
         MOVE WS-MIN-TICKS TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
         MOVE WS-TICKS TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-A2
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L2
         MOVE BR-IN-CURSOR TO WS-RC
         PERFORM RAISE-NOW
     ELSE
         MOVE WS-TICKS TO L-INT
     END-IF.

*> ---- uuid (§6.3): five groups of 1 to 16 hexadecimal digits separated by - ---------------------------
 DO-UUID.
     MOVE BR-IN-CURSOR TO WS-START
     MOVE WS-START TO WS-C
     PERFORM UNTIL WS-C >= BR-IN-LENGTH
         MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
         IF WS-CH = "-" OR (WS-CH >= "0" AND WS-CH <= "9") OR (WS-CH >= "a" AND WS-CH <= "f")
                 OR (WS-CH >= "A" AND WS-CH <= "F")
             ADD 1 TO WS-C
         ELSE
             EXIT PERFORM
         END-IF
     END-PERFORM
     MOVE 1 TO WS-VALID
     MOVE 1 TO WS-GROUPS
     MOVE 0 TO WS-GROUP-DIGITS
     PERFORM VARYING WS-I FROM WS-START BY 1 UNTIL WS-I >= WS-C
         IF BR-IN-TEXT(WS-I + 1:1) = "-"
             IF WS-GROUP-DIGITS = 0
                 MOVE 0 TO WS-VALID
             END-IF
             ADD 1 TO WS-GROUPS
             MOVE 0 TO WS-GROUP-DIGITS
         ELSE
             ADD 1 TO WS-GROUP-DIGITS
             IF WS-GROUP-DIGITS > 16
                 MOVE 0 TO WS-VALID
             END-IF
         END-IF
     END-PERFORM
     IF WS-GROUP-DIGITS = 0 OR WS-GROUPS NOT = 5
         MOVE 0 TO WS-VALID
     END-IF
     IF WS-VALID = 1
         MOVE WS-C TO BR-IN-CURSOR
     ELSE
         MOVE "argument.uuid.invalid" TO WS-KEY
         MOVE WS-START TO WS-RC
         PERFORM RAISE-PLAIN
     END-IF.

*> ---- the scoreboard types (§6.4) ------------------------------------------------------------------
*> objective and team: readUnquotedString (the lookup is the command's).
 DO-WORD.
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
     MOVE WS-C TO BR-IN-CURSOR.

*> The text up to the next space into WS-STR (WS-RUN-START, WS-STR-LENGTH); the cursor is left after it.
 TAKE-TEXT.
     MOVE BR-IN-CURSOR TO WS-RUN-START
     MOVE WS-RUN-START TO WS-C
     PERFORM UNTIL WS-C >= BR-IN-LENGTH OR BR-IN-TEXT(WS-C + 1:1) = SPACE
         ADD 1 TO WS-C
     END-PERFORM
     COMPUTE WS-STR-LENGTH = WS-C - WS-RUN-START
     MOVE SPACES TO WS-STR
     IF WS-STR-LENGTH > 0
         MOVE BR-IN-TEXT(WS-RUN-START + 1:WS-STR-LENGTH) TO WS-STR(1:WS-STR-LENGTH)
     END-IF
     MOVE WS-C TO BR-IN-CURSOR.

 DO-OPERATION.
     PERFORM TAKE-TEXT
     CALL "BR-ENUM-INDEX" USING WS-L-OPERATION WS-STR WS-STR-LENGTH WS-INDEX
     IF WS-INDEX >= 0
         MOVE WS-INDEX TO L-INT
     ELSE
         MOVE "arguments.operation.invalid" TO WS-KEY
         MOVE WS-C TO WS-RC
         PERFORM RAISE-PLAIN
     END-IF.

*> A fixed criterion name, teamkill.<colour>, killedByTeam.<colour>, or <stat type>:<value> with a known stat
*> type (the stat value registries are data of the game and are not checked here).
 DO-CRITERIA.
     PERFORM TAKE-TEXT
     MOVE 0 TO WS-VALID
     CALL "BR-ENUM-INDEX" USING WS-L-CRITERIA WS-STR WS-STR-LENGTH WS-INDEX
     IF WS-INDEX >= 0
         MOVE 1 TO WS-VALID
     END-IF
     IF WS-VALID = 0 AND WS-STR-LENGTH > 9 AND WS-STR(1:9) = "teamkill."
         COMPUTE WS-PART-END = WS-STR-LENGTH - 9
         MOVE SPACES TO WS-TAIL
         MOVE WS-STR(10:WS-PART-END) TO WS-TAIL
         CALL "BR-ENUM-INDEX" USING WS-L-COLOR WS-TAIL WS-PART-END WS-INDEX
         IF WS-INDEX >= 0
             MOVE 1 TO WS-VALID
         END-IF
     END-IF
     IF WS-VALID = 0 AND WS-STR-LENGTH > 13 AND WS-STR(1:13) = "killedByTeam."
         COMPUTE WS-PART-END = WS-STR-LENGTH - 13
         MOVE SPACES TO WS-TAIL
         MOVE WS-STR(14:WS-PART-END) TO WS-TAIL
         CALL "BR-ENUM-INDEX" USING WS-L-COLOR WS-TAIL WS-PART-END WS-INDEX
         IF WS-INDEX >= 0
             MOVE 1 TO WS-VALID
         END-IF
     END-IF
     IF WS-VALID = 0
         PERFORM STAT-CRITERION
     END-IF
     IF WS-VALID = 0
         MOVE "argument.criteria.invalid" TO WS-KEY
         MOVE WS-RUN-START TO WS-RC
         PERFORM RAISE-TEXT
     END-IF.

 STAT-CRITERION.
     MOVE 0 TO WS-COLON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-STR-LENGTH
         IF WS-STR(WS-I:1) = ":"
             IF WS-COLON = 0
                 MOVE WS-I TO WS-COLON
             ELSE
                 MOVE -1 TO WS-COLON
             END-IF
         END-IF
     END-PERFORM
     IF WS-COLON > 1 AND WS-COLON < WS-STR-LENGTH
         COMPUTE WS-PART-END = WS-COLON - 1
         CALL "BR-ENUM-INDEX" USING WS-L-STATS WS-STR WS-PART-END WS-INDEX
         IF WS-INDEX >= 0
             MOVE 1 TO WS-VALID
         END-IF
     END-IF.

*> ---- item slots (§6.6) -----------------------------------------------------------------------------
 DO-SLOT.
     PERFORM TAKE-TEXT
     CALL "BR-SLOT-LOOKUP" USING WS-STR WS-STR-LENGTH WS-SLOT-COUNT WS-SLOTS
     EVALUATE TRUE
         WHEN WS-SLOT-COUNT = 0
             MOVE "slot.unknown" TO WS-KEY
             MOVE WS-C TO WS-RC
             PERFORM RAISE-TEXT
         WHEN WS-SLOT-COUNT > 1 AND BR-N-TYPE(L-NODE) = BR-P-ITEM-SLOT
             MOVE "slot.only_single_allowed" TO WS-KEY
             MOVE WS-C TO WS-RC
             PERFORM RAISE-TEXT
         WHEN OTHER
             MOVE WS-SLOT(1) TO L-INT
             MOVE WS-SLOT-COUNT TO BR-V-IVAL2
     END-EVALUATE.

*> ---- identifiers and the types built on them (§6.7, §6.8) -------------------------------------------
*> The identifier at the cursor (BR-READ-ID); # is allowed in front of a tag name for the *-or-tag types and function.
 DO-IDENTIFIER.
     MOVE 0 TO WS-ID-FLAGS
     IF BR-N-TYPE(L-NODE) = BR-P-RES-OR-TAG OR BR-N-TYPE(L-NODE) = BR-P-RES-OR-TAG-KEY
             OR BR-N-TYPE(L-NODE) = BR-P-FUNCTION
         MOVE 1 TO WS-ID-FLAGS
     END-IF
     IF BR-N-TYPE(L-NODE) = BR-P-RES-SELECTOR
         MOVE 2 TO WS-ID-FLAGS
     END-IF
     CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
     IF BR-E-KEY = SPACES AND BR-N-REG-LENGTH(L-NODE) > 0 AND (BR-N-TYPE(L-NODE) = BR-P-RESOURCE
             OR BR-N-TYPE(L-NODE) = BR-P-RES-OR-TAG OR BR-N-TYPE(L-NODE) = BR-P-RES-OR-TAG-KEY)
             AND NOT (WS-ID-START > 0 AND BR-IN-TEXT(WS-ID-START:1) = "#")
         PERFORM CHECK-REGISTRY
     END-IF.

*> The identifier just read (WS-ID-START, WS-ID-LENGTH) must be an entry of the registry BR-N-REG of the node (15 §6.7: the content API,
*> CONTENT-REGISTRY-COUNT and -ENTRY): without a namespace it is in the namespace of the content set (cobolcraft: for the cobolcraft
*> set, else minecraft:); an unknown one is argument.resource.not_found [identifier, registry] with the cursor back at its start.
*> A registry the open set does not hold is not checked.
 CHECK-REGISTRY.
     MOVE SPACES TO WS-REG-WANT WS-REG-KEY
     MOVE BR-N-REG(L-NODE) TO WS-REG-KEY
     MOVE 0 TO WS-REG-HAS-COLON
     PERFORM VARYING WS-I FROM WS-ID-START BY 1 UNTIL WS-I >= WS-ID-START + WS-ID-LENGTH
         IF BR-IN-TEXT(WS-I + 1:1) = ":"
             MOVE 1 TO WS-REG-HAS-COLON
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-REG-ALT
     MOVE 0 TO WS-REG-ALT-LENGTH
     IF WS-REG-HAS-COLON = 1
         MOVE BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) TO WS-REG-WANT
         MOVE WS-ID-LENGTH TO WS-REG-WANT-LENGTH
     ELSE
         STRING "minecraft:" BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-REG-ALT
         COMPUTE WS-REG-ALT-LENGTH = WS-ID-LENGTH + 10
         IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
             STRING "cobolcraft:" BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-REG-WANT
             COMPUTE WS-REG-WANT-LENGTH = WS-ID-LENGTH + 11
         ELSE
             STRING "minecraft:" BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-REG-WANT
             COMPUTE WS-REG-WANT-LENGTH = WS-ID-LENGTH + 10
         END-IF
     END-IF
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REG-KEY WS-REG-COUNT WS-REG-STATUS
     IF WS-REG-STATUS = CT-OK
         MOVE 0 TO WS-REG-FOUND
         PERFORM VARYING WS-REG-ID FROM 0 BY 1 UNTIL WS-REG-ID >= WS-REG-COUNT OR WS-REG-FOUND = 1
             CALL "CONTENT-REGISTRY-ENTRY" USING WS-REG-KEY WS-REG-ID WS-REG-ENTRY WS-REG-ENTRY-LENGTH
                 WS-REG-PAYLOAD WS-REG-CAPACITY WS-REG-PAYLOAD-LENGTH WS-REG-STATUS
             IF WS-REG-ENTRY-LENGTH = WS-REG-WANT-LENGTH
                     AND WS-REG-ENTRY(1:WS-REG-ENTRY-LENGTH) = WS-REG-WANT(1:WS-REG-WANT-LENGTH)
                 MOVE 1 TO WS-REG-FOUND
             END-IF
             IF WS-REG-ALT-LENGTH > 0 AND WS-REG-ENTRY-LENGTH = WS-REG-ALT-LENGTH
                     AND WS-REG-ENTRY(1:WS-REG-ENTRY-LENGTH) = WS-REG-ALT(1:WS-REG-ALT-LENGTH)
                 MOVE 1 TO WS-REG-FOUND
             END-IF
         END-PERFORM
         IF WS-REG-FOUND = 0
             MOVE "argument.resource.not_found" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-REG-WANT-LENGTH TO WS-L1
             IF WS-L1 > 64
                 MOVE 64 TO WS-L1
             END-IF
             MOVE WS-REG-WANT(1:WS-L1) TO WS-A1(1:WS-L1)
             MOVE BR-N-REG-LENGTH(L-NODE) TO WS-L2
             MOVE BR-N-REG(L-NODE)(1:WS-L2) TO WS-A2(1:WS-L2)
             MOVE WS-ID-START TO WS-RC
             PERFORM RAISE-NOW
         END-IF
     END-IF.

*> Types that take an identifier, or an inline definition in braces (loot and provider types, dialog, feature); the
*> context providers also take a number.
 DO-RESOURCE-OR-INLINE.
     MOVE BR-IN-CURSOR TO WS-C
     MOVE SPACE TO WS-CH
     IF WS-C < BR-IN-LENGTH
         MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
     END-IF
     EVALUATE TRUE
         WHEN WS-CH = "{"
             CALL "BR-SNBT-VALUE" USING WS-SNBT-KIND
         WHEN (WS-CH = "-" OR WS-CH = "." OR (WS-CH >= "0" AND WS-CH <= "9"))
                 AND (BR-N-TYPE(L-NODE) = BR-P-CTX-FLOAT OR BR-N-TYPE(L-NODE) = BR-P-CTX-INT)
             CALL "BR-READ-PLAIN" USING WS-KIND-DOUBLE WS-INT WS-DOUBLE WS-INF
         WHEN OTHER
             PERFORM DO-IDENTIFIER
     END-EVALUATE.

 DO-RANGE.
     CALL "BR-READ-RANGE" USING WS-RANGE-KIND WS-RANGE-AUX L-INT WS-RANGE-I2 L-DOUBLE WS-RANGE-D2
     MOVE WS-RANGE-AUX TO BR-V-AUX
     MOVE WS-RANGE-I2 TO BR-V-IVAL2
     MOVE WS-RANGE-D2 TO BR-V-DVAL2.

 MAIN-LINE.
     MOVE 0 TO L-INT L-DOUBLE L-INF
     MOVE SPACES TO BR-E-KEY
     EVALUATE BR-N-TYPE(L-NODE)
         WHEN BR-P-GAMEMODE
         WHEN BR-P-ANCHOR
         WHEN BR-P-MIRROR
         WHEN BR-P-TEMPLATE-ROT
         WHEN BR-P-HEIGHTMAP
         WHEN BR-P-SWING
         WHEN BR-P-TEAM-COLOR
         WHEN BR-P-SLOT-DISPLAY
             PERFORM DO-ENUM
         WHEN BR-P-HEX-COLOR
             PERFORM DO-HEX
         WHEN BR-P-TIME
             PERFORM DO-TIME
         WHEN BR-P-INT-RANGE
             MOVE 0 TO WS-RANGE-KIND
             PERFORM DO-RANGE
         WHEN BR-P-FLOAT-RANGE
             MOVE 1 TO WS-RANGE-KIND
             PERFORM DO-RANGE
         WHEN BR-P-UUID
             PERFORM DO-UUID
         WHEN BR-P-OBJECTIVE
         WHEN BR-P-TEAM
             PERFORM DO-WORD
         WHEN BR-P-OPERATION
             PERFORM DO-OPERATION
         WHEN BR-P-CRITERIA
             PERFORM DO-CRITERIA
         WHEN BR-P-ITEM-SLOT
         WHEN BR-P-ITEM-SLOTS
             PERFORM DO-SLOT
         WHEN BR-P-RESLOC
         WHEN BR-P-FUNCTION
         WHEN BR-P-DIMENSION
         WHEN BR-P-RES-OR-TAG
         WHEN BR-P-RES-OR-TAG-KEY
         WHEN BR-P-RESOURCE
         WHEN BR-P-RESOURCE-KEY
         WHEN BR-P-RES-SELECTOR
             PERFORM DO-IDENTIFIER
         WHEN BR-P-LOOT-TABLE
         WHEN BR-P-LOOT-PREDICATE
         WHEN BR-P-LOOT-MODIFIER
         WHEN BR-P-CTX-FLOAT
         WHEN BR-P-CTX-INT
         WHEN BR-P-DIALOG
         WHEN BR-P-FEATURE
             PERFORM DO-RESOURCE-OR-INLINE
         WHEN BR-P-BLOCK-STATE
         WHEN BR-P-BLOCK-PREDICATE
         WHEN BR-P-ITEM-STACK
         WHEN BR-P-ITEM-PREDICATE
             CALL "BR-ARG-BLOCK" USING L-NODE L-INT L-DOUBLE L-INF
         WHEN BR-P-COMPONENT
         WHEN BR-P-STYLE
         WHEN BR-P-NBT-COMPOUND
         WHEN BR-P-NBT-TAG
             CALL "BR-ARG-NBT" USING L-NODE
         WHEN BR-P-NBT-PATH
             CALL "BR-ARG-NBT-PATH"
         WHEN BR-P-ENTITY
         WHEN BR-P-GAME-PROFILE
         WHEN BR-P-SCORE-HOLDER
         WHEN BR-P-MESSAGE
             CALL "BR-ARG-ENTITY" USING L-NODE L-INT L-DOUBLE L-INF
         WHEN BR-P-BLOCK-POS
         WHEN BR-P-COLUMN-POS
         WHEN BR-P-VEC3
         WHEN BR-P-VEC2
         WHEN BR-P-ROTATION
         WHEN BR-P-ANGLE
         WHEN BR-P-SWIZZLE
             CALL "BR-ARG-COORD" USING L-NODE L-INT L-DOUBLE L-INF
         WHEN OTHER
             MOVE BR-IN-CURSOR TO WS-C
             PERFORM UNTIL WS-C >= BR-IN-LENGTH OR BR-IN-TEXT(WS-C + 1:1) = SPACE
                 ADD 1 TO WS-C
             END-PERFORM
             MOVE WS-C TO BR-IN-CURSOR
     END-EVALUATE.
 END PROGRAM BR-ARG-EXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-READ-RANGE.
*> USING kind (0 integer range, 1 float range, 2 degree range), aux out (1 minimum, 2 maximum, 3 both present), integer
*> minimum out, integer maximum out, double minimum out, double maximum out: the range of 15 §6.9 from BR-IN-CURSOR (a
*> single number is both bounds). The degree range has no swapped check and fails with parsing.float.invalid. A
*> failure sets BR-E-KEY (argument.range.empty, argument.range.swapped, the number errors) with the cursor reset to the
*> start of the range where the document says so; success leaves the cursor after the range.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-START               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-RUN-START           BINARY-LONG.
 01 WS-RUN-END             BINARY-LONG.
 01 WS-RUN-1-START         BINARY-LONG.
 01 WS-RUN-1-END           BINARY-LONG.
 01 WS-RUN-2-START         BINARY-LONG.
 01 WS-RUN-2-END           BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-CH                  PIC X.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-AUX                  BINARY-LONG.
 01 L-INT1                 BINARY-DOUBLE.
 01 L-INT2                 BINARY-DOUBLE.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-AUX L-INT1 L-INT2 L-D1 L-D2.
     GO TO MAIN-LINE.

 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

 RAISE-TEXT.
     MOVE 1 TO WS-N-ARGS
     MOVE SPACES TO WS-A1
     MOVE WS-STR-LENGTH TO WS-L1
     IF WS-L1 > 64
         MOVE 64 TO WS-L1
     END-IF
     IF WS-L1 > 0
         MOVE BR-IN-TEXT(WS-RUN-START + 1:WS-L1) TO WS-A1(1:WS-L1)
     END-IF
     PERFORM RAISE-NOW.

 RAISE-PLAIN.
     MOVE 0 TO WS-N-ARGS
     PERFORM RAISE-NOW.

*> ---- ranges (§6.9) ---------------------------------------------------------------------------
*> From WS-C: the longest run of 0-9 and - and a . that is not followed by another . (WS-RUN-START to WS-RUN-END, 0-based).
 SCAN-NUMBER-RUN.
     MOVE WS-C TO WS-RUN-START
     MOVE 1 TO WS-VALID
     PERFORM UNTIL WS-C >= BR-IN-LENGTH OR WS-VALID = 0
         MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
         EVALUATE TRUE
             WHEN (WS-CH >= "0" AND WS-CH <= "9") OR WS-CH = "-"
                 ADD 1 TO WS-C
             WHEN WS-CH = "."
                 IF WS-C + 1 < BR-IN-LENGTH AND BR-IN-TEXT(WS-C + 2:1) = "."
                     MOVE 0 TO WS-VALID
                 ELSE
                     ADD 1 TO WS-C
                 END-IF
             WHEN OTHER
                 MOVE 0 TO WS-VALID
         END-EVALUATE
     END-PERFORM
     MOVE WS-C TO WS-RUN-END.

 DO-RANGE.
     MOVE BR-IN-CURSOR TO WS-START
     MOVE WS-START TO WS-C
     IF WS-START >= BR-IN-LENGTH
         MOVE "argument.range.empty" TO WS-KEY
         MOVE WS-START TO WS-RC
         PERFORM RAISE-PLAIN
     ELSE
         PERFORM SCAN-NUMBER-RUN
         MOVE WS-RUN-START TO WS-RUN-1-START
         MOVE WS-RUN-END TO WS-RUN-1-END
         MOVE 0 TO WS-RUN-2-START WS-RUN-2-END WS-TAG
         IF WS-C + 1 < BR-IN-LENGTH AND BR-IN-TEXT(WS-C + 1:2) = ".."
             MOVE 1 TO WS-TAG
             ADD 2 TO WS-C
             PERFORM SCAN-NUMBER-RUN
             MOVE WS-RUN-START TO WS-RUN-2-START
             MOVE WS-RUN-END TO WS-RUN-2-END
         END-IF
         IF WS-RUN-1-END = WS-RUN-1-START AND (WS-TAG = 0 OR WS-RUN-2-END = WS-RUN-2-START)
             MOVE "argument.range.empty" TO WS-KEY
             MOVE WS-C TO WS-RC
             PERFORM RAISE-PLAIN
         ELSE
             PERFORM RANGE-BOUNDS
         END-IF
     END-IF.

*> The bounds of the runs; a single value is both. An invalid number resets the cursor to the start of the range.
 RANGE-BOUNDS.
     MOVE 0 TO L-AUX
     MOVE WS-RUN-1-START TO WS-RUN-START
     COMPUTE WS-STR-LENGTH = WS-RUN-1-END - WS-RUN-1-START
     IF WS-STR-LENGTH > 0
         PERFORM CONVERT-RUN
         IF BR-E-KEY = SPACES
             MOVE WS-INT TO L-INT1
             MOVE WS-DOUBLE TO L-D1
             MOVE 1 TO L-AUX
             IF WS-TAG = 0
                 MOVE WS-INT TO L-INT2
                 MOVE WS-DOUBLE TO L-D2
                 MOVE 3 TO L-AUX
             END-IF
         END-IF
     END-IF
     IF BR-E-KEY = SPACES AND WS-TAG = 1 AND WS-RUN-2-END > WS-RUN-2-START
         MOVE WS-RUN-2-START TO WS-RUN-START
         COMPUTE WS-STR-LENGTH = WS-RUN-2-END - WS-RUN-2-START
         PERFORM CONVERT-RUN
         IF BR-E-KEY = SPACES
             MOVE WS-INT TO L-INT2
             MOVE WS-DOUBLE TO L-D2
             ADD 2 TO L-AUX
         END-IF
     END-IF
     IF BR-E-KEY = SPACES AND L-AUX = 3
         IF (L-KIND = 0 AND L-INT1 > L-INT2)
                 OR (L-KIND = 1 AND L-D1 > L-D2)
             MOVE "argument.range.swapped" TO WS-KEY
             MOVE WS-START TO WS-RC
             PERFORM RAISE-PLAIN
         END-IF
     END-IF
     IF BR-E-KEY = SPACES
         MOVE WS-C TO BR-IN-CURSOR
     END-IF.

*> The run at WS-RUN-START of WS-STR-LENGTH characters: an optional -, digits, for a float range one dot; an integer
*> within 32 bits. Sets WS-INT and WS-DOUBLE (both) or raises parsing.int.invalid or parsing.double.invalid.
 CONVERT-RUN.
     MOVE 1 TO WS-VALID
     MOVE 0 TO WS-DIGITS WS-DOTS WS-INT
     MOVE 1 TO WS-I
     MOVE 0 TO WS-SIGN
     IF BR-IN-TEXT(WS-RUN-START + 1:1) = "-"
         MOVE 1 TO WS-SIGN
         MOVE 2 TO WS-I
     END-IF
     PERFORM VARYING WS-I FROM WS-I BY 1 UNTIL WS-I > WS-STR-LENGTH
         MOVE BR-IN-TEXT(WS-RUN-START + WS-I:1) TO WS-CH
         EVALUATE TRUE
             WHEN WS-CH >= "0" AND WS-CH <= "9"
                 ADD 1 TO WS-DIGITS
             WHEN WS-CH = "."
                 ADD 1 TO WS-DOTS
             WHEN OTHER
                 MOVE 0 TO WS-VALID
         END-EVALUATE
     END-PERFORM
     IF WS-DIGITS = 0 OR WS-DOTS > 1
         MOVE 0 TO WS-VALID
     END-IF
     IF L-KIND = 0 AND WS-DOTS > 0
         MOVE 0 TO WS-VALID
     END-IF
     IF WS-VALID = 1
         IF L-KIND = 0
             IF WS-DIGITS > 10
                 MOVE 0 TO WS-VALID
             ELSE
                 MOVE FUNCTION NUMVAL(BR-IN-TEXT(WS-RUN-START + 1:WS-STR-LENGTH)) TO WS-INT
                 IF WS-INT > 2147483647 OR WS-INT < -2147483648
                     MOVE 0 TO WS-VALID
                 END-IF
             END-IF
             MOVE WS-INT TO WS-DOUBLE
         ELSE
             COMPUTE WS-DOUBLE = FUNCTION NUMVAL(BR-IN-TEXT(WS-RUN-START + 1:WS-STR-LENGTH))
             MOVE 0 TO WS-INT
         END-IF
     END-IF
     IF WS-VALID = 0
         EVALUATE L-KIND
             WHEN 0
                 MOVE "parsing.int.invalid" TO WS-KEY
             WHEN 1
                 MOVE "parsing.double.invalid" TO WS-KEY
             WHEN OTHER
                 MOVE "parsing.float.invalid" TO WS-KEY
         END-EVALUATE
         MOVE WS-START TO WS-RC
         PERFORM RAISE-TEXT
     END-IF.

 MAIN-LINE.
     MOVE 0 TO L-AUX L-INT1 L-INT2 L-D1 L-D2
     MOVE SPACES TO BR-E-KEY
     PERFORM DO-RANGE.
 END PROGRAM BR-READ-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-READ-ID.
*> USING flags (1 a leading # is allowed, 2 a * is a character of the name), start out (cursor of the name after the #),
*> length out: the identifier of 15 §6.7 from BR-IN-CURSOR: the longest run of the characters 0-9 a-z _ : / . - at most
*> one colon, a namespace of a-z 0-9 _ - . and a path of a-z 0-9 _ - / . (the namespace may not hold /). An invalid
*> run resets the cursor and raises argument.id.invalid; an empty one is valid (the minecraft namespace and an empty path).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-START               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-HAS-COLON           BINARY-LONG.
 01 WS-COLON-AT            BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-START L-LENGTH.
     MOVE BR-IN-CURSOR TO WS-START
     MOVE WS-START TO WS-C
     IF FUNCTION MOD(L-FLAGS, 2) = 1 AND WS-C < BR-IN-LENGTH AND BR-IN-TEXT(WS-C + 1:1) = "#"
         ADD 1 TO WS-C
     END-IF
     MOVE WS-C TO L-START
     MOVE 0 TO WS-HAS-COLON WS-COLON-AT
     MOVE 1 TO WS-VALID
     PERFORM UNTIL WS-C >= BR-IN-LENGTH
         MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
         EVALUATE TRUE
             WHEN (WS-CH >= "0" AND WS-CH <= "9") OR (WS-CH >= "a" AND WS-CH <= "z")
                     OR WS-CH = "_" OR WS-CH = "/" OR WS-CH = "." OR WS-CH = "-"
                 CONTINUE
             WHEN WS-CH = ":"
                 ADD 1 TO WS-HAS-COLON
                 MOVE WS-C TO WS-COLON-AT
                 IF WS-HAS-COLON > 1
                     MOVE 0 TO WS-VALID
                 END-IF
             WHEN WS-CH = "*" AND L-FLAGS >= 2
                 CONTINUE
             WHEN OTHER
                 EXIT PERFORM
         END-EVALUATE
         ADD 1 TO WS-C
     END-PERFORM
     IF WS-HAS-COLON = 1
         PERFORM VARYING WS-I FROM L-START BY 1 UNTIL WS-I >= WS-COLON-AT
             IF BR-IN-TEXT(WS-I + 1:1) = "/"
                 MOVE 0 TO WS-VALID
             END-IF
         END-PERFORM
     END-IF
     COMPUTE L-LENGTH = WS-C - L-START
     IF WS-VALID = 1
         MOVE WS-C TO BR-IN-CURSOR
     ELSE
         MOVE "argument.id.invalid" TO WS-KEY
         MOVE WS-START TO WS-RC
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     END-IF
     GOBACK.
 END PROGRAM BR-READ-ID.
